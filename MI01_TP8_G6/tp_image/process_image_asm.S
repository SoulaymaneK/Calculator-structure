/*  process_image_asm.S
 
    MI01 - TP Assembleur 2 à 5

    Réalise le traitement d'une image bitmap 32 bits par pixel.
*/

.file "process_image_asm.S"
.intel_syntax noprefix

.text

/***********************************************************************
  Sous-programme process_image_asm 
    
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

.global process_image_asm
process_image_asm:
            push    rbp
            mov     rbp, rsp


            /***********************************************************
              Conversion en niveaux de gris
             **********************************************************/ 

            # Calcul du nombre de pixels de l'image dans rdi.
            push    rdi           # Sauvegarde de la largeur de l'image
            imul    rdi, rsi      # rdi <- largeur x hauteur

            /* On itère sur chaque pixel en partant du dernier pixel
            jusqu'au premier pixel. rdi contient en fait le nombre de 
            pixels restants à traiter. */
loop_gs:

            /***********************************************************
              Ajoutez votre code pour la partie 1 (niveaux de gris) ici
             **********************************************************/

            sub     rdi, 1        # Un pixel de moins à traiter
            /*mov		dword ptr [rcx + rdi*4 - 4], 0xff0000ff    rdx pour l'image tempon*/

            movzx 	ax, byte ptr[rdx + rdi*4 - 2] /*composante bleue*/
            movzx 	r10w, byte ptr[rdx + rdi*4 - 3] /*composante verte*/
            imul 	ax, 0x0013 /*coef bleu*/
      		imul 	r10w, 0x00B7 /*coef vert*/
      		movzx 	r11w, byte ptr[rdx + rdi*4 - 4] /*composante rouge*/
      		add 	ax,r10w
      		imul 	r11w, 0x0036 /*coef rouge*/
      		add 	ax,r11w
      		mov 	byte ptr[rcx + rdi*4 - 1], 0xff /*opacité maximale*/
      		mov 	byte ptr[rcx + rdi*4 - 4], ah /*valeur de I dans la composante rouge*/
      		//mov 	byte ptr[rcx + rdi*4 - 3], ah /*valeur de I dans la composante rouge*/
      		//mov 	byte ptr[rcx + rdi*4 - 2], ah /*valeur de I dans la composante rouge*/

            ja      loop_gs

            pop     rdi           # rdi <- largeur de l'image en pixesls

            jmp     epilogue      # Supprimer ce saut pour activer le détecteur de contours


            /***********************************************************
              Détecteur de contours de Sobel

              Ajoutez votre code pour la partie 2 (Sobel) ici
             **********************************************************/ 

          	 push     rsi
			 push     rbx
			 push     r12
			 push     r14


	         lea	r11, [rcx] /*pointeur source*/
	         lea 	r10, [r8 + rdi*4 +4] /*pointeur destination*/


             sub	rsi,2
			 mov 	r12, rdi //colonnes resteantes

 loop_ligne:
              //traitement des colonnes

             mov 	rdi,r12
             sub	rdi, 2

             loop_colonne:
 				xor	rax, rax
				xor	rdx, rdx
				xor rbx, rbx
				// Calcul de G_x ( masque Sx)
				sub ax, word ptr[r11]					//	a11 * (-1)
				add ax, word ptr[r11 + 8]				//+	a31 * 1
				sub ax, word ptr[r11 + r12*4]			//+ a12 * (-2)
				sub ax, word ptr[r11 + r12*4]
				add ax, word ptr[r11 + r12*4 + 8]		//+ a32 * 2
				add ax,word ptr [r11 + r12*4 + 8]
				sub ax, word ptr[r11 + r12*8]			//+ a13 * (-1)
				add ax, word ptr[r11 + r12*8 +8]		//+ a33 * 1

				//Calcul de G_y (masque Sy)
				add bx,word ptr [r11]					//	a11 * 1
				add bx, word ptr[r11+4]					//+ a21 * 2
				add bx, word ptr[r11+4]
				add bx, word ptr[r11+8]					//+ a31 * 1
				sub bx, word ptr[r11 + r12*8]			//+ a13 * (-1)
				sub bx, word ptr[r11 + r12*8 + 4]		//+ a23 * (-2)
				sub bx, word ptr[r11 + r12*8 + 4]
				sub bx, word ptr[r11 + r12*8 + 8]		//+ a33 * (-1)

				// Valeur abs(G_x)
				 CWD			// dx:ax ← ax avec ext. de signe
				 xor ax, dx
				 sub ax, dx

				mov r14w, ax

				// Valeur abs(G_y)
				mov ax, bx
				CWD
				xor ax, dx
				sub ax, dx
				/*cmp   ax, 0
		        jge   g_x_positif
		        neg   ax
		  g_x_positif:
		      // Valeur abs(G_y) : si G_y < 0 on prendra - G_y
		        cmp   bx, 0
		        jge   g_y_positif
		        neg   bx
		  g_y_positif:*/

				// Calcul final de G
				add ax, r14w
				neg ax
				add ax, 255
				cmp ax,0
				jge suite
				xor ax, ax

		suite:


				mov byte ptr [r10],al
				mov byte ptr [r10+3],0xff
				mov byte ptr[r10 + 1], al
				mov byte ptr[r10 + 2], al

	            lea 	r11, [r11+4]
	            lea 	r10, [r10 + 4]
	            sub 	rdi, 1
	            jg 	loop_colonne

             lea 	r11, [r11+8]
             lea 	r10, [r10 + 8]
			 sub 	rsi, 1
             jg  	loop_ligne




epilogue:

			//pop r14
			//pop r12
			//pop rbx
            //pop	rsi
			pop rbp           # Dépiler le pointeur de cadre de pile sauvegardé
            ret                   # Retour à l'appelant












