import 'package:mp3/utils/db_helper.dart';

class Flashcard {
  int? id;
  int deckId;
  String question;
  String answer;

  Flashcard({
    required this.id,
    required this.deckId,
    required this.question,
    required this.answer,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'deckId': deckId,
      'question': question,
      'answer': answer,
    };
  }

  static Flashcard fromMap(flashcardMap) {
    return Flashcard(
      id: flashcardMap['id'] as int,
      deckId: flashcardMap['deckId'] as int,
      question: flashcardMap['question'] as String,
      answer: flashcardMap['answer'] as String,
    );
  }

  Future<void> dbSave() async {
    // update our id with the newly inserted record's id
    id = await DBHelper().insert('flashcard', {
      'question': question,
      'answer': answer,
      'deckId': deckId,
    });
  }

  Future<void> dbUpdate() async {
    await DBHelper().update('flashcard', {
      'question': question,
      'answer': answer,
      'deckId': deckId,
    }, 'id = ?', [id]);
  }

  Future<void> dbDelete() async {
    if (id != null) {
      await DBHelper().delete('flashcard', 'id = ?', [id]);
    }
  }
}
