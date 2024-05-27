import 'package:flutter/material.dart';
import 'package:mp3/models/deck.dart';
import 'package:mp3/utils/db_helper.dart';

class DeckEditor extends StatefulWidget {
  const DeckEditor({
    super.key,
    required this.deckIndex,
    required this.deckTitle,
    required this.decks,
    required this.isBeingCreated,
  });

  final int deckIndex;
  final String deckTitle;
  final List<Deck> decks;
  final bool isBeingCreated;

  @override
  State<DeckEditor> createState() => _DeckEditorState();
}


class _DeckEditorState extends State<DeckEditor> {
  final TextEditingController _deckNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (!widget.isBeingCreated) {
      _deckNameController.text = widget.deckTitle;
    }
  }

  Future<void> createOrUpdateDeck() async {
    final String newDeckTitle = _deckNameController.text;

    // Create a new deck and insert it into the database
    if (widget.isBeingCreated) {
      final newDeck = Deck(title: newDeckTitle, flashcards: []);
      await DBHelper().insert('deck', {'title': newDeckTitle});
      widget.decks.add(newDeck);
    } else {
      // Update the deck in the database
      for (final deck in widget.decks) {
        if (deck.title == widget.deckTitle) {
          await DBHelper().update(
            'deck',
            {'title': newDeckTitle},
            'id = ?',
            [deck.id],
          );
          deck.title = newDeckTitle;
          break;
        }
      }
    }
    if (mounted) {
      Navigator.pop(context, widget.decks);
    }
  }

  // Future<void> deleteDeck() async {
  //   widget.decks.removeWhere((deck) {
  //     if (deck.id == widget.deckIndex) {
  //       for (final flashcard in deck.flashcards) {
  //         deleteFromDB(flashcard.id);
  //       }
  //       return true;
  //     }
  //     return false;
  //   });
  //   await DBHelper().delete('deck', 'id = ?', [widget.deckIndex]);
  //   if (mounted) {
  //     Navigator.pop(context, widget.decks);
  //   }
  // }

  // Future<void> deleteFromDB(flashcardId) async {
  //   await DBHelper().delete('flashcard', 'id = ?', [flashcardId]);
  // }

  Future<void> deleteDeck() async {
    await DBHelper().deleteDeckAndRelatedFlashcards(widget.deckIndex);
    if (mounted) {
      Navigator.pop(context, widget.decks);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = !widget.isBeingCreated;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[400],
        title: Center(
          child: Text(
            isEditing ? 'Edit Deck' : 'Create Deck',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () {
            Navigator.pop(context, widget.decks);
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
                controller: _deckNameController,
                decoration: const InputDecoration(
                  labelText: 'Deck Name',
                  labelStyle: TextStyle(fontWeight: FontWeight.bold),
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
                    onPressed: createOrUpdateDeck,
                    child: const Text('Save'),
                  ),
                  const SizedBox(width: 16),
                  if (!widget.isBeingCreated)
                    TextButton(
                      style: ButtonStyle(
                        foregroundColor: MaterialStateProperty.all(Colors.white),
                        backgroundColor: MaterialStateProperty.all(Colors.red[300]),
                      ),
                      onPressed: deleteDeck,
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