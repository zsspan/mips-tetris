# mips-tetris

Welcome to my implementation of the classic game Tetris, _but ... written entirely in **MIPS Assembly**!_

This game was developed for CSCB58: Computer Organization, and highlits the transition from digital circuits and hardware into software language. You can find a brief design document titled ```MIPS Tetris - B58 Final Design Document.pdf``` with a concise overview. **View the video demonstration on [YouTube](https://youtu.be/1i9ZrxbfWmI)**.

<img width="321" height="331" alt="mips" src="https://github.com/user-attachments/assets/a28ffde2-82a4-4b09-9915-83774e7d7730" /> <img height="350" alt="image" src="https://github.com/user-attachments/assets/632cbc13-b765-4963-81bf-4086fd54dfe2" />



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

- Use ASD for left/down/right, W for rotate, and H to hold!

## Design Explanation (Simplified)
- Uses IO polling to get keyboard inputs
- Forces a game loop consisting of drawing a piece to the framebuffer, handling collisions, locking pieces, and generating a new one
- Handles scoring, gravity, RNG, and game ending
