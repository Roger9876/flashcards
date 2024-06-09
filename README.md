# Flashcards App

Create decks of flashcards, add questions and answers, and test your knowledge by running quizzes.

## Getting Started

### Prerequisites

Ensure you have the following installed on your development machine:

- Flutter SDK
- Dart SDK
- A suitable IDE such as Visual Studio Code or Android Studio
- An emulator or physical device for testing

### Installation

1. Clone the repository from GitHub:

   ```sh
   git clone https://github.com/Roger9876/flashcards.git
   ```

2. Navigate to the project directory:

   ```sh
   cd flashcards
   ```

3. Install the necessary dependencies:

   ```sh
   flutter pub get
   ```

4. Run the application:

   ```sh
   flutter run
   ```

## How to Play

1. **Deck List Page**: Start by creating a new deck or selecting an existing one from the list.
   - **Create Deck**: Tap the "Create Deck" button and enter a title for your new deck.
   - **Select Deck**: Tap an existing deck to view its cards.

2. **Card List Page**: View and manage the flashcards within the selected deck.
   - **Create Card**: Tap the "Add Card" button and enter the question and answer.
   - **Edit Card**: Tap on a card to edit its question and answer.
   - **Sort Cards**: Sort cards alphabetically or by creation date using the sorting options.

3. **Quiz Page**: Run a quiz with the cards from the selected deck.
   - **Start Quiz**: Tap the "Start Quiz" button to shuffle and display the flashcards.
   - **View Question**: Initially see the question on the flashcard.
   - **Peek Answer**: Tap to reveal the answer.
   - **Navigate**: Use forward and backward buttons to navigate through the cards.

        ![Flashacards](./assets/gameplay.png)

## Features

- **Deck Management**: Create, edit, delete, and view decks.
- **Flashcard Management**: Create, edit, sort, and delete flashcards within a deck.
- **Quizzes**: Run quizzes with shuffled flashcards from a selected deck.
- **Persistence**: Save decks and flashcards to a local SQLite database.
- **Responsive Design**: Adapt the UI to different screen sizes.

## Implementation

- **External Packages**:
  - `provider`: State management
  - `collection`: Data structure operations
  - `sqflite`: SQLite database
  - `path_provider`: Access filesystem locations
  - `path`: Path manipulation

- **Database**:
  - `sqflite` to persist data with separate tables for decks and cards, linked by a foreign key.

- **Navigation**:
  - `Navigator` for managing page transitions.

- **JSON Initialization**:
  - To load initial data from `assets/flashcards.json`.

- **Code Structure**:
  - Modularized code with separate directories for views, models, and utilities.

- **Asynchronous Operations**:
  - To manage database operations asynchronously and display loading indicators during lengthy operations.

## Contact

For any questions or issues, please contact:

- Name: Raviraj Khopade
- Email: <rmkhopade21@gmail.com>
