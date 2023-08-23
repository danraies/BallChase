# BallChase

This is a simple game made in Love2D.  I don't claim that it's necessarily "fun", but it does work.  It was made in a couple of days to try and get a feel for Love2D.

### How do I get this to run on my computer?
1. First, [download and install Love2D](https://love2d.org/) on your computer.  It is supported on Windows, MacOS, and Linux.
1. Get the code from this repository into a folder on your computer.  If you know how to fork a repository on github and pull it with git then you should do that.  Otherwise just click "\<\> Code" in the top right, then "Download ZIP", and extract the folder to anywhere you'd like.  You should have a folder called BallChase containing two files: main.lua and Hack-Regular.ttf.  Other files are fine, but those are the only two that matter.
1. Running the game is different depending on the operating system.
    * On Windows, drag the folder called BallChase (not the file called main.lua) and drop it onto love.exe (or a shortcut to love.exe).
    * On MacOS, drag the folder called BallChase (not the file called main.lua) and drop it onto the love application bundle.
    * On Linux, enter the following into the console: `love /path/to/BallChase`

### Controls and Objectives:
* Player 1 is a blue circle and Player 2 (if present) is a red circle.
* Player 1 uses the WASD keys to move and Player 2 uses the arrow keys to move.
* Collecting the green circle increases the player's score by 1.  Collecting the white circles with crosses through them results in the player's score decreasing by 1.
* In a single player game, the goal is to score as many points as possible in 30 seconds.  In a two player game, the goal is to have a higher score than your opponent at the end of 30 seconds.

### Notes:
* I did not make the font used by the code (`Hack-Regular.ttf`).  I believe that the liscense allows me to use it here but if that is not the case, I am happy to replace it.  I found the it here: https://github.com/source-foundry/Hack.
* I made sure to keep the code in one file.  It might be cleaner with a few classes here and there (`Mine`, `Goal`, `Player` for example) but as a restriction on myself I wanted to minimize complexity.
* There are many optimizations that can be made.  Off the top of my head there are `if`/`then` blocks that get repeated, there are a few calls to `love.graphics.setColor` that could be avoided by rearranging `love.draw`, and there are many operations that are done in `love.draw` and `love.update` that could be moved to `love.load`.  I'm sure there are many others.  I was more interested in readable code than efficiency.
* There are a lot of gameplay refinements that could be made.  Here are some examples: On the results screen it would be nice if the player could go right into another game instead of back to the title screen.  There should probably be some instructions on the title screen.  There is not enough visual distinction between the goal and the player(s).  It would be more fun if the players in two-player mode could interact with each other, perhaps with some kind of bounce or even just through collision.
* I think it would be fun to add physics.  Right now the player uses arrow keys to impart a velocity vector in one of eight directions; the player must hold the key(s) in order for the ball to move.  I have an idea where once the player's ball starts moving it never stops moving and the player can use the arrow keys to change the direction of travel.  Then it would be interesting to add collision between everything.  When the player collides with the goal, a mine, another player, or a wall they should bounce using elastic collisions.