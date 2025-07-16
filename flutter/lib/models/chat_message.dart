import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType {
  text,
  image,
  system,
}

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final bool isMe;
  final String? imageUrl;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.content,
    required this.type,
    required this.timestamp,
    required this.isMe,
    this.imageUrl,
  });

  factory ChatMessage.fromFirestore(DocumentSnapshot doc, int currentUserId) {
    final data = doc.data() as Map<String, dynamic>;

    return ChatMessage(
      id: doc.id,
      senderId: data['sender_id']?.toString() ?? '',
      senderName: data['sender_name'] ?? 'Unknown',
      senderAvatar: data['sender_avatar'],
      content: data['content'] ?? '',
      type: _parseMessageType(data['type']),
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isMe: (data['sender_id'] ?? 0) == currentUserId,
      imageUrl: data['image_url'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'sender_id': int.parse(senderId),
      'sender_name': senderName,
      'sender_avatar': senderAvatar,
      'content': content,
      'type': type.name,
      'timestamp': FieldValue.serverTimestamp(),
      'image_url': imageUrl,
    };
  }

  static MessageType _parseMessageType(String? type) {
    switch (type) {
      case 'image':
        return MessageType.image;
      case 'system':
        return MessageType.system;
      default:
        return MessageType.text;
    }
  }
}

class ChatRoom {
  final String id;
  final String kompetisiId;
  final String name;
  final List<int> participants;
  final ChatMessage? lastMessage;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChatRoom({
    required this.id,
    required this.kompetisiId,
    required this.name,
    required this.participants,
    this.lastMessage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatRoom.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ChatRoom(
      id: doc.id,
      kompetisiId: data['kompetisi_id']?.toString() ?? '',
      name: data['name'] ?? '',
      participants: List<int>.from(data['participants'] ?? []),
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updated_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'kompetisi_id': int.parse(kompetisiId),
      'name': name,
      'participants': participants,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    };
  }
}
