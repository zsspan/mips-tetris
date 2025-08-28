# 🧩mips-tetris

Welcome to my implementation of the classic game Tetris, _but ... written entirely in **MIPS Assembly**!_

This game was developed for CSCB58: Computer Organization, and highlits the transition from digital circuits and hardware into software language. You can find a brief design document titled ```MIPS Tetris - B58 Final Design Document.pdf``` with a concise overview. **View the video demonstration on [YouTube](https://youtu.be/1i9ZrxbfWmI)**.

<div style="display: flex; justify-content: center; align-items: center; gap: 10px;">
  <img width="321" height="331" alt="mips" src="https://github.com/user-attachments/assets/a28ffde2-82a4-4b09-9915-83774e7d7730" />
  <img width="500" height="331" alt="image" src="https://github.com/user-attachments/assets/cceb9c00-9024-43c7-acdd-8c7783871557" />
</div>



## Game Features
- All tetronimoes represented (with different colours)
- Holding functionality
- Movement, including rotation
- Incremental Gravity (levels get harder as you progress)
- Line clearing and score counter

## Get Started
- Use a MIPS emulator, ex: [MARS](https://dpetersanderson.github.io/) or [Saturn](https://1whatleytay.github.io/saturn)
--> _Note that Saturn works in browser, so you can copy-paste_ ```tetris.asm``` _directly into the editor, set the Bitmap controls and start playing immediately_
- Set the Bitmap display as follows:


<img width="432" height="194" alt="image" src="https://github.com/user-attachments/assets/e23b93a7-700c-4c97-9834-05b9f12aeb74" />

## Design Explanation (Simplified)
- Uses IO polling to get keyboard inputs (ASD for left/down/right, W for rotate, H to hold, Q to quit)
- Forces a game loop consisting of drawing a piece to the framebuffer, handling collisions, locking pieces, and generating a new one
- Handles scoring, gravity, RNG, and game ending
