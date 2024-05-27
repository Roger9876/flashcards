import 'package:flutter/material.dart';
import 'package:mp3/models/deck.dart';
import 'package:mp3/models/flashcard.dart';
import 'package:mp3/utils/db_helper.dart';

class QuizPage extends StatefulWidget {
  final String deckTitle;
  final List<Deck> decks;
  final int deckId;

  const QuizPage({
    super.key,
    required this.deckTitle,
    required this.decks,
    required this.deckId,
  });

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  late Future<List<Flashcard>> _flashcards;
  List<Flashcard> flashcards = [];
  final List questionsShown = [];
  List listOfIndexes = [];
  int currentQueIndex = 0;
  int revealedAnswers = 0;
  int totalAnsweredQuestions = 0;
  bool isAnswerVisible = false;
  bool greenBackgroundEnabled = false;

  Future<List<Flashcard>> loadFlashcards() async {
    final flashcards1 = await DBHelper().query(
      'flashcard',
      where: 'deckId = ${widget.deckId}',
    );
    List<Flashcard> mappedFlashcards = flashcards1
        .map((e) => Flashcard(
              id: e['id'] as int,
              deckId: e['deckId'] as int,
              question: e['question'] as String,
              answer: e['answer'] as String,
            ))
        .toList();
    updateQuestionProgress(currentQueIndex);
    mappedFlashcards.shuffle();
    return mappedFlashcards;
  }

  @override
  void initState() {
    super.initState();
    _flashcards = loadFlashcards();
  }

  void revealAnswer() {
    setState(() {
      if (!isAnswerVisible) {
        isAnswerVisible = true;
        greenBackgroundEnabled = true;
        final currentQue = flashcards[currentQueIndex].question;
        if (!questionsShown.contains(currentQue)) {
          questionsShown.add(currentQue);
          revealedAnswers++;
        }
      } else {
        isAnswerVisible = false;
        greenBackgroundEnabled = false;
      }
    });
  }

  void updateQuestionProgress(queIndex) {
    setState(() {
      isAnswerVisible = false;
      greenBackgroundEnabled = false;
      if (!listOfIndexes.contains(queIndex) &&
          listOfIndexes.length < flashcards.length + 1) {
        listOfIndexes.add(queIndex);
        totalAnsweredQuestions++;
      }
    });
  }

  void loadNextQuestion() {
    setState(() {
      currentQueIndex = (currentQueIndex + 1) % flashcards.length;
      updateQuestionProgress(currentQueIndex);
    });
  }

  void loadPreviousQuestion() {
    setState(() {
      currentQueIndex =
          (currentQueIndex - 1 + flashcards.length) % flashcards.length;
      updateQuestionProgress(currentQueIndex);
    });
  }

  int displayTotalAnsweredQuestions() {
    return totalAnsweredQuestions == 0 ? 1 : totalAnsweredQuestions;
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
                  Navigator.pop(context);
                },
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 32,
                    height: (MediaQuery.of(context).size.height * 0.5) - 32,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      color: greenBackgroundEnabled
                          ? Colors.green[300]
                          : Colors.indigoAccent[100],
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            isAnswerVisible
                                ? flashcards[currentQueIndex].answer!
                                : flashcards[currentQueIndex].question!,
                            style: const TextStyle(fontSize: 18),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: loadPreviousQuestion,
                        icon: const Icon(Icons.arrow_back_ios_rounded),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        onPressed: revealAnswer,
                        icon: isAnswerVisible
                            ? const Icon(Icons.lock_open_rounded)
                            : const Icon(Icons.lock_rounded),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        onPressed: loadNextQuestion,
                        icon: const Icon(Icons.arrow_forward_ios_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Seen $totalAnsweredQuestions of ${flashcards.length} cards',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Peeked at $revealedAnswers of ${displayTotalAnsweredQuestions()} answers',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
