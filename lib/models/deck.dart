import 'package:mp3/utils/db_helper.dart';

import 'flashcard.dart';

class Deck {
  int? id;
  String title;
  List<Flashcard> flashcards;

  Deck({
    this.id,
    required this.title,
    required this.flashcards,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'flashcards': flashcards.map((flashcard) => flashcard.toMap()).toList(),
    };
  }

  Deck fromMap(Map<String, dynamic> map) {
    List<dynamic> flashcardsList = map['flashcards'];
    return Deck(
      id: map['id'] as int,
      title: map['title'] as String,
      flashcards: flashcardsList
          .map((flashcard) =>
              Flashcard.fromMap(flashcard as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<void> dbSave() async {
    id = await DBHelper().insert('deck', {
      'title': title,
    });
  }

  Future<void> dbUpdate() async {
    await DBHelper().update('deck', {
      'title': title,
    }, 'id = ?', [id]);
  }

  Future<void> dbDelete() async {
    if (id == null) {
      await DBHelper().delete('deck', 'id = ?', [id]);
    }
  }
}
