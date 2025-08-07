# Project Overview

This project is a web application that to play a variant of coinche with 5 players.
For now, the application provides just the essential visual support for playing the game, but the players have to be able to communicate with each other to play the game, e.g., through a video call (in particular, for the bidding phase).
In the future, it could be extended to support different numbers of players and different game modes.

## Libraries and Frameworks

- Lamdera application (https://lamdera.com/) which means the Elm language is used for both the frontend and backend.
- Elm UI for the frontend.

## Folder Structure

- `/src/Backend.elm`: Contains the backend code.
- `/src/Frontend.elm`: Contains the frontend code.
- `/src/Types.elm`: Contains the type definitions and shared logic.
- `/src/Env.elm`: Unused for now, but could be used for defining secrets.
- `/src/Evergreen`: Contains the evergreen migrations from one version of the application to another.

## Coding Recommendations

- Use Elm's type system to ensure safety and correctness (e.g., try as much as possible to make illegal states unrepresentable).
- Install and run the Elm formatter at each commit to maintain code style.
- Use `lamdera check --force` to generate evergreen migrations when necessary (`--force` is needed to bypass the check that we are on the main branch).
  - Commit the generated migration files.
  - Implement the missing cases in the migration files in a separate commit to ease review.

## Testing

Testing in local mode is a little bit tricky, because we need 5 players for the game to start and each player needs to have its own browser session. One way to achieve this is to use the Firefox Container extension, which allows you to create separate containers for each player.

- Run `lamdera live` to start the local server.
- Use the Firefox Container extension to create 5 containers, one for each player.
- Open `http://localhost:8000` in each container and enter a different player name for each container.

Take screenshots of the game in action to demonstrate the functionality.
