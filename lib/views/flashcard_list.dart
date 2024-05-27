import 'package:flutter/material.dart';
import 'package:mp3/models/deck.dart';
import 'package:mp3/models/flashcard.dart';
import 'package:mp3/utils/db_helper.dart';
import 'package:mp3/views/flashcard_editor.dart';
import 'package:mp3/views/quiz.dart';

// ignore: must_be_immutable
class FlashcardList extends StatefulWidget {
  final int deckId;
  final String deckTitle;
  List<Deck> decks = [];

  FlashcardList({
    super.key,
    required this.deckId,
    required this.deckTitle,
    required this.decks,
  });

  @override
  State<FlashcardList> createState() => _FlashcardListState();
}

class _FlashcardListState extends State<FlashcardList> {
  late Future<List<Flashcard>> _flashcards;
  List<Flashcard> baseFlashcards = [];
  List<Flashcard> flashcards = [];
  bool isSorted = false;
  bool isEmpty = false;

  Future<List<Flashcard>> loadFlashcards() async {
    final flashcard = await DBHelper().query(
      'flashcard',
      where: 'deckId = ${widget.deckId}',
    );
    return flashcard
        .map((e) => Flashcard(
              id: e['id'] as int,
              deckId: e['deckId'] as int,
              question: e['question'] as String,
              answer: e['answer'] as String,
            ))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _flashcards = loadFlashcards();
    _flashcards.then((value) => {
      if (value.isEmpty) {
        isEmpty = true,
        loadLocalFlashcards()
      },
    });
  }

  void loadLocalFlashcards() {
    for (final deck in widget.decks) {
      if (deck.id == widget.deckId) {
        flashcards = deck.flashcards;
        break;
      }
    }
    setState(() {
      flashcards = flashcards;
    });
  }

  void toggleSortCards() {
    setState(() {
      if (!isSorted) {
        baseFlashcards = List.from(flashcards);
        flashcards.sort((a, b) => a.question.compareTo(b.question));
        isSorted = true;
      } else {
        flashcards = List.from(baseFlashcards);
        isSorted = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _flashcards,
      initialData: const [],
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          flashcards =
              snapshot.hasData ? snapshot.data as List<Flashcard> : flashcards;
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.green[400],
              title: Center(
                child: Text(
                  widget.deckTitle,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white),
                onPressed: () {
                  Navigator.pop(context, true);
                },
              ),
              actions: <Widget>[
                IconButton(
                  icon: const Icon(Icons.sort, color: Colors.white),
                  onPressed: isEmpty ? null : toggleSortCards,
                  disabledColor: Colors.grey,
                ),
                IconButton(
                  icon:
                      const Icon(Icons.play_arrow_rounded, color: Colors.white),
                  disabledColor: Colors.grey,
                  onPressed: isEmpty
                      ? null
                      : () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QuizPage(
                                deckTitle: widget.deckTitle,
                                deckId: widget.deckId,
                                decks: widget.decks,
                              ),
                            ),
                          );
                        },
                ),
              ],
            ),
            body: GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 250,
                childAspectRatio: 1,
              ),
              itemCount: flashcards.length,
              itemBuilder: (context, index) {
                return Card(
                  color: Colors.blue[100],
                  child: InkWell(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FlashcardEditor(
                              initialQue: flashcards[index].question,
                              initialAns: flashcards[index].answer,
                              deckId: widget.deckId,
                              flashcardId: flashcards[index].id ?? 0,
                              decks: widget.decks,
                              canBeDeleted: true),
                        ),
                      ).then((value) => {
                          if (value == true)
                            {
                              setState(() {
                                _flashcards =
                                    loadFlashcards();
                              })
                            }
                        });
                    },
                    child: Center(
                      child: Text(
                        flashcards[index].question,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                );
              },
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FlashcardEditor(
                        initialQue: '',
                        initialAns: '',
                        deckId: widget.deckId,
                        flashcardId: 0,
                        decks: widget.decks,
                        canBeDeleted: false),
                  ),
                ).then((value) => {
                    if (value == true)
                      {
                        setState(() {
                          _flashcards =
                            loadFlashcards();
                            if (isEmpty) {
                              isEmpty = false;
                            }
                        })
                      }
                  });
              },
              child: const Icon(Icons.add),
            ),
          );
        }
      },
    );
  }
}
