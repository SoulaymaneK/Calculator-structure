/*  process_image_simd.S
 
    MI01 - TP Assembleur 2 à 5

    Réalise le traitement d'une image bitmap 32 bits par pixel.
    Implémentation SIMD
*/

.file "process_image_simd.S"
.intel_syntax noprefix

.text

/***********************************************************************
  Sous-programme process_image_simd
    
  Réalise le traitement d'une image 32 bits.
  
  Le passage des paramètres respecte les conventions x64 sous Linux
  
  Par registres :
            Largeur de l'image : rdi
            Hauteur de l'image : rsi
            Pointeur sur l'image source : rdx
            Pointeur sur l'image tampon 1 : rcx
            Pointeur sur l'image tampon 2 : r8
            Pointeur sur l'image finale : r9  
  
  Les registes rbx, rbp, r12, r13, r14, et r15 doivent être sauvegardés
  si vous les utilisez (sauvegarde par l'appelé). Les autres registres 
  peuvent être modifiés sans risque (sauvegardés par l'appelant).
***********************************************************************/

.global process_image_simd
process_image_simd:  
            push    rbp
            mov     rbp, rsp

            /***********************************************************
              Ajoutez votre code ici
            ***********************************************************/
			push rdi
			imul rdi, rsi

            //mov eax, 0x0013B736
            mov eax, 0x00095B1B
            movd xmm1, eax
            punpckldq xmm1,xmm1 // copie des 32 bits de poids faibles sur le second bloc de 32  bits
    		punpcklqdq xmm1,xmm1 // copie des 64 bits de poids faibles sur les 64 bits restants
    		movdqa  xmm0, [rdx + rdi*4 - 16]
            loop_gs:
            	sub     rdi, 4
			    movdqa  xmm0, [rdx + rdi*4 - 16] /*deplacement du groupe de pixels, vers un registre SSE*/

			    pmaddubsw xmm0,xmm1
			    pxor   xmm2,xmm2
                phaddw xmm0,xmm2
                paddw xmm0,xmm0 // multiplication par 2
                punpcklwd xmm0,xmm2
                psrlw xmm0, 8 // decalage de 1 octets, placement de l'intensite
                pcmpeqq xmm2,xmm2
                pslld xmm2,24
                paddb xmm0,xmm2
                movdqa [rcx + rdi*4 - 16], xmm0

			    ja loop_gs
			pop rdi
			pop  rbp
            ret

