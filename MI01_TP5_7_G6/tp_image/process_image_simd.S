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

			// On cree le vecteur qui va contenir les constantes
			// 00bleuvertrouge...
			// a la fin, ca va etre dans xmm1
			// mov rax, 0x0013B7360013B736 // ca c'est l'original
			mov rax, 0x00095B0500095B05 //ca avec les modifs demandees par le sujet (on multiplie par 2 exposant 7), puis on divisera le resultat apres par 2^7
			movq xmm1, rax
			pslldq xmm1, 8


			movq xmm2, rax
			por xmm1, xmm2

			pxor xmm2, xmm2





loop_gs:
			 sub     rdi, 4        # 4 pixels de moins à traiter

			// on met tous les pixels a traiter dans xmm1

			mov rax, qword ptr[rdx+rdi*4]
			movq xmm0, rax
			pslldq xmm0, 8

			mov rax, qword ptr[rdx+rdi*4+8]
			movq xmm2, rax
			por xmm1, xmm2

			pxor xmm2, xmm2

			pmaddubsw xmm0, xmm1 // chaque case sera des word
			phaddw xmm0, xmm0

			// faut convertir ces valeurs en word
			// on peut faire comme ca

			punpcklwd xmm0, xmm0

			// ensuite on decale chaque word de 2^-7
			pslld xmm0, 7


			//ensuite faut appliquer un masque pour obtenir une opacite de ff

			// et enfin on replace les valeurs d'intensite dans les pixels associes







			ja      loop_gs

			pop rdi
            pop     rbp
            ret
