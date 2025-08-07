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

## Development Setup

- Install the Lamdera CLI and Elm formatter using Nix:
  ```bash
  nix-shell -p elmPackages.lamdera elmPackages.elm-format
  ```

## Coding Recommendations

- Use Elm's type system to ensure safety and correctness (e.g., try as much as possible to make illegal states unrepresentable).
- Run the Elm formatter at each commit to maintain code style.
- Use `lamdera check --force` to generate evergreen migrations when necessary (`--force` is needed to bypass the check that we are on the main branch).
  - Commit the generated migration files.
  - Implement the missing cases in the migration files in a separate commit to ease review.

### Responsive Design Guidelines

When implementing UI components in this Elm UI application:

#### Sizing

- **Avoid fixed pixel values** for card dimensions and spacing
- **Use constraint-based sizing**: `fill |> minimum X |> maximum Y` for flexible elements
- **Prefer relative spacing** over fixed pixel values
- **Test on multiple screen sizes** (mobile: 375px, tablet: 768px, desktop: 1200px+)

#### Layout Patterns

- **Use `wrappedRow`** for elements that should wrap on small screens (trump selector, card hands)
- **Use `row` with reduced spacing** for elements that should stay horizontal but be closer together
- **Consider `column` layouts** for mobile-first approaches on very small screens

#### Testing Responsive Design

- Create responsive demos/prototypes using simple HTML/CSS to validate concepts
- Test wrapping behavior by resizing browser windows
- Verify touch targets are appropriately sized for mobile (minimum 44px touch areas)

#### Elm UI Responsive Features to Leverage

- `fill |> minimum X |> maximum Y` for flexible sizing
- `wrappedRow` for automatic wrapping layouts
- `spacing` with smaller values for mobile-friendly interfaces
- `paddingXY` and `paddingEach` for fine-tuned spacing control

## Testing

Testing in local mode is a little bit tricky, because we need 5 players for the game to start and each player needs to have its own browser session. One way to achieve this is to use the Firefox Container extension, which allows you to create separate containers for each player.

- Run `lamdera make` to detect any compilation errors.
- Run `lamdera live` to start the local server.
- Use the Firefox Container extension (or equivalent) to create 5 containers, one for each player.
- Open `http://localhost:8000` in each container and enter a different player name for each container.

Take screenshots of the game in action to demonstrate the functionality.
