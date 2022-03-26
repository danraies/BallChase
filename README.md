# BallChase

This is a simple game made in Love2D.  I don't claim that it's necessarily "fun", but it does work.  It was made in a couple of days to try and get a feel for Love2D.

Here are some notes:
* I did not make the font used by the code (`Hack-Regular.ttf`).  I believe that the liscense allows me to use it here but if that is not the case, I am happy to replace it.  I found the it here: https://github.com/source-foundry/Hack.
* I made sure to keep the code in one file.  It might be cleaner with a few classes here and there (`Mine`, `Goal`, `Player` for example) but as a restriction on myself I wanted to minimize complexity.
* There are many optimizations that can be made.  Off the top of my head there are `if`/`then` blocks that get repeated, there are a few calls to `love.graphics.setColor` that could be avoided by rearranging `love.draw`, and there are many operations that are done in `love.draw` and `love.update` that could be moved to `love.load`.  I'm sure there are many others.  I was more interested in readable code than efficiency.
* There are a lot of gameplay refinements that could be made.  Here are some examples: On the results screen it would be nice if the player could go right into another game instead of back to the title screen.  There should probably be some instructions on the title screen.  There is not enough visual distinction between the goal and the player(s).  It would be more fun if the players in two-player mode could interact with each other, perhaps with some kind of bounce or even just through collision.
* I think it would be fun to add physics.  Right now the player uses arrow keys to impart a velocity vector in one of eight directions; the player must hold the key(s) in order for the ball to move.  I have an idea where once the player's ball starts moving it never stops moving and the player can use the arrow keys to change the direction of travel.  Then it would be interesting to add collision between everything.  When the player collides with the goal, a mine, another player, or a wall they should bounce using elastic collisions.