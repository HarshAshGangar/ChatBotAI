  import 'package:flutter/material.dart';
  import 'package:flutter/foundation.dart' show immutable;
  import 'package:json_annotation/json_annotation.dart';

  @immutable
  @JsonSerializable()
  class Message {
    final String id;
    final String message;
    final String? imageURL;
    final DateTime createdAT;
    final bool isMine;

    const Message({
      required this.id,
      required this.message,
      this.imageURL,
      required this.createdAT,
      required this.isMine,
    });

    /// Converts the Message object to a map.
    Map<String, dynamic> toMap() {
      return <String, dynamic>{
        'id': id,
        'message': message,
        'imageURL': imageURL,
        'createdAT': createdAT.millisecondsSinceEpoch,
        'isMine': isMine,
      };
    }

    /// Creates a Message instance from a map.
    factory Message.fromMap(Map<String, dynamic> map) {
      return Message(
        id: map['id'] as String,
        message: map['message'] as String,
        imageURL: map['imageURL'] as String?,
        createdAT: DateTime.fromMillisecondsSinceEpoch(map['createdAT'] as int),
        isMine: map['isMine'] as bool,
      );
    }
    Message copyWith({
      String? imageUrl,
    }) {
      return Message(
        id: id,
        message: message,
        imageURL: imageUrl ?? this.imageURL,  // Use the new imageUrl if provided
        createdAT: createdAT,
        isMine: isMine,
      );
    }
  }

