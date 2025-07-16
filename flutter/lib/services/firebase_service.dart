import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_message.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<void> initializeFirebaseAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');
      final userEmail =
          prefs.getString('user_email') ?? 'user$userId@hydratrack.app';

      if (userId != null) {
        // Sign in anonymously or with custom token
        if (_auth.currentUser == null) {
          await _auth.signInAnonymously();
        }
      }
    } catch (e) {
      print('Error initializing Firebase Auth: $e');
    }
  }

  static Future<ChatRoom> createChatRoom(String kompetisiId,
      String kompetisiName, List<int> participantIds) async {
    try {
      final chatRoomId = 'comp_$kompetisiId';
      final chatRoomRef = _firestore.collection('chat_rooms').doc(chatRoomId);

      final doc = await chatRoomRef.get();

      if (!doc.exists) {
        final chatRoom = ChatRoom(
          id: chatRoomId,
          kompetisiId: kompetisiId,
          name: 'Chat $kompetisiName',
          participants: participantIds,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await chatRoomRef.set(chatRoom.toFirestore());

        await sendSystemMessage(
          chatRoomId,
          'Selamat datang di grup chat kompetisi $kompetisiName! 🎉',
        );

        return chatRoom;
      } else {
        return ChatRoom.fromFirestore(doc);
      }
    } catch (e) {
      throw Exception('Failed to create chat room: $e');
    }
  }

  static Future<void> sendMessage(String chatRoomId, String content) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');
      final userName = prefs.getString('user_name') ?? 'User';

      if (userId == null) throw Exception('User not logged in');

      final message = ChatMessage(
        id: '',
        senderId: userId.toString(),
        senderName: userName,
        content: content,
        type: MessageType.text,
        timestamp: DateTime.now(),
        isMe: true,
      );

      await _firestore
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .add(message.toFirestore());

      await _firestore
          .collection('chat_rooms')
          .doc(chatRoomId)
          .update({'updated_at': FieldValue.serverTimestamp()});
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  static Future<void> sendSystemMessage(
      String chatRoomId, String content) async {
    try {
      final message = ChatMessage(
        id: '',
        senderId: 'system',
        senderName: 'System',
        content: content,
        type: MessageType.system,
        timestamp: DateTime.now(),
        isMe: false,
      );

      await _firestore
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .add(message.toFirestore());
    } catch (e) {
      print('Error sending system message: $e');
    }
  }

  static Stream<List<ChatMessage>> getMessagesStream(String chatRoomId) {
    final prefs = SharedPreferences.getInstance();

    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots()
        .asyncMap((snapshot) async {
      final preferences = await prefs;
      final currentUserId = preferences.getInt('user_id') ?? 0;

      return snapshot.docs
          .map((doc) => ChatMessage.fromFirestore(doc, currentUserId))
          .toList();
    });
  }

  static Future<void> sendAchievementMessage(
      String chatRoomId, String userName, String achievement) async {
    await sendSystemMessage(
      chatRoomId,
      '🏆 $userName baru saja meraih pencapaian: $achievement!',
    );
  }

  static Future<void> sendWaterIntakeUpdate(
      String chatRoomId, String userName, double amount,
      [int? rank]) async {
    String message;

    if (rank != null) {
      String rankEmoji = '';
      if (rank == 1)
        rankEmoji = '🏆';
      else if (rank == 2)
        rankEmoji = '🥈';
      else if (rank == 3) rankEmoji = '🥉';

      message =
          '💧 $userName baru saja minum ${amount.toStringAsFixed(1)}L air! $rankEmoji Peringkat #$rank';
    } else {
      message =
          '💧 $userName baru saja minum ${amount.toStringAsFixed(1)}L air!';
    }

    await sendSystemMessage(chatRoomId, message);
  }

  static Future<ChatRoom?> getChatRoom(String chatRoomId) async {
    try {
      final doc =
          await _firestore.collection('chat_rooms').doc(chatRoomId).get();
      if (doc.exists) {
        return ChatRoom.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting chat room: $e');
      return null;
    }
  }

  static Future<void> deleteChatRoom(String chatRoomId) async {
    try {
      final messagesQuery = await _firestore
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .get();

      for (final doc in messagesQuery.docs) {
        await doc.reference.delete();
      }

      await _firestore.collection('chat_rooms').doc(chatRoomId).delete();
    } catch (e) {
      print('Error deleting chat room: $e');
    }
  }
}
