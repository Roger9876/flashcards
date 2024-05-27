import 'package:flutter/material.dart';
import 'package:mp3/models/deck.dart';
import 'package:mp3/models/flashcard.dart';
import 'package:mp3/utils/db_helper.dart';

class FlashcardEditor extends StatefulWidget {
  final String initialQue;
  final String initialAns;
  final int deckId;
  final int flashcardId;
  final List<Deck> decks;
  final bool canBeDeleted;

  const FlashcardEditor({
    super.key,
    required this.initialQue,
    required this.initialAns,
    required this.canBeDeleted,
    required this.decks,
    required this.deckId,
    required this.flashcardId,
  });
  @override
  State<FlashcardEditor> createState() => _FlashcardEditorState();
}

class _FlashcardEditorState extends State<FlashcardEditor> {
  TextEditingController queController = TextEditingController();
  TextEditingController ansController = TextEditingController();

  @override
  void initState() {
    super.initState();
    queController.text = widget.initialQue;
    ansController.text = widget.initialAns;
  }

  @override
  void dispose() {
    queController.dispose();
    ansController.dispose();
    super.dispose();
  }

  void applyChanges() async {
    String updatedQue = queController.text;
    String updatedAns = ansController.text;

    // If the flashcard is new, add it to the deck
    if (!widget.canBeDeleted) {
      Flashcard newFlashcard = Flashcard(
        id: DateTime.now().millisecondsSinceEpoch,
        deckId: widget.deckId,
        question: updatedQue,
        answer: updatedAns,
      );

      widget.decks.map((deck) {
        if (deck.id == widget.deckId) {
          return Deck(
            // id: DateTime.now().millisecondsSinceEpoch,
            title: deck.title,
            flashcards: [...deck.flashcards, newFlashcard],
          );
        }
        return deck;
      }).toList();
      await DBHelper().insert('flashcard', {
        'deckId': widget.deckId,
        'question': updatedQue,
        'answer': updatedAns,
      });
      if (mounted) {
        Navigator.pop(context, true);
      }

    } else {
      // If the flashcard is being edited, update it in the deck
      widget.decks.map((deck) {
        if (deck.id == widget.deckId) {
          List<Flashcard> updatedFlashcards = deck.flashcards.map((flashcard) {
            if (flashcard.question == widget.initialQue) {
              return Flashcard(
                id: widget.flashcardId,
                deckId: widget.deckId,
                question: updatedQue,
                answer: updatedAns,
              );
            }
            return flashcard;
          }).toList();
          return Deck(
            id: widget.deckId,
            title: deck.title,
            flashcards: updatedFlashcards,
          );
        }
        return deck;
      }).toList();
      await DBHelper().update('flashcard', {
        'question': updatedQue,
        'answer': updatedAns,
      }, 'id = ?', [widget.flashcardId]);
      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  // Remove flashcard from database
  void deleteFlashcard() async {
    await DBHelper().delete('flashcard', 'id = ?', [widget.flashcardId]);
    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[400],
        title: const Center(
          child: Text(
            'Flashcard Editor',
            style: TextStyle(color: Colors.white),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: queController,
                decoration: const InputDecoration(
                  labelText: 'Question',
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: ansController,
                decoration: const InputDecoration(
                  labelText: 'Answer',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    style: ButtonStyle(
                        foregroundColor: MaterialStateProperty.all(Colors.white),
                        backgroundColor: MaterialStateProperty.all(Colors.blue[300]),
                      ),
                    onPressed: applyChanges,
                    child: const Text('Save'),
                  ),
                  const SizedBox(width: 16),
                  if (widget.canBeDeleted)
                    TextButton(
                      style: ButtonStyle(
                        foregroundColor: MaterialStateProperty.all(Colors.white),
                        backgroundColor: MaterialStateProperty.all(Colors.red[300]),
                      ),
                      onPressed: deleteFlashcard,
                      child: const Text('Delete'),
                    ),
                ],
              ),
            ],
          ),
        )
      ),
    );
  }
}
