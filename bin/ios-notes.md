Write a really good plan before generating a task. Refactoring takes forever.

Be aware that writing to many tests make things slow.

Probably smart to run both the build and tests in the loop and print to file, so we use the same simulator every time.
Then a new session can process the logs and fix issues.

Really great to fix errors with Xcode's calude integration.

Dont make the tasks way to small, then everything takes forever.

Dont run the UI tests with code. 


Probably better to ralph in the beginning for logic, and claude it regularly when working with the UI


https://sudoku.one/fobidoshi
https://sudoku.one/renban



Add the following tasks where relevant in the tasks.md file:
-The first 50 puzzles are located in a file here that you should copy: /Users/einar/Sites/utvikler-einar-hansen/tennergrid-web/puzzles.json
-Update difficulties to: Easy = 55%, Medium = 45%, Hard = 35% and Extreme = 25%. The backend/API is already updates. 
-When the user input a value that exists in the notes of another cell in the same row or nearest neighbour, then update the notes in the cell to exclude the solved number.
-Add the ability to zoom in and out (make table larger) by using two fingers, or with buttons on devices that doesnt have touchscreen (macos). 
-If we hide invalid options is enabled, then the invalid options should be hidden for notes as well.
-If we have existing notes in a cell, and we are in "notes off" mode, looking to set a value. Then make the numbers that are in the notes in a different color (of your choice) to highlight that they are special.
-The playtime timer when playing game must pause when we go ton another app or leave the app to go to the homescreen. At the moment is pausing the game when the app reopens, which is not accurate as the timer is running while in the background. 
-Wire up so that the settings work button work when we are in the game, and also the button when we have the pause screen
-Make sure button to start the game on "daily challenge" works. Right now the game is not starting.


Neste er backend for å hente spill og dele statistikk
