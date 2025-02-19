import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class Event {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final DateTime from;

  @HiveField(4)
  final DateTime to;

  @HiveField(5)
  final int backgroundColor;

  @HiveField(6)
  final String image;

  @HiveField(7)
  final String markerId;

  @HiveField(8)
  final String typeId;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.from,
    required this.to,
    required this.backgroundColor,
    required this.image,
    required this.markerId,
    required this.typeId,
  });

   Color get _backgroundColor => Color(backgroundColor);

    factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      from: DateTime.parse(json['from']),
      to: DateTime.parse(json['to']),
      backgroundColor: json['backgroundColor'], //อ่านค่า int กลับมา 
      image: json['image'],
      markerId: json['markerId'],
      typeId: json['typeId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id':id,
      'title': title,
      'description': description,
      'from': from.toIso8601String(),
      'to': to.toIso8601String(),
      'backgroundColor': _backgroundColor, //เก็บค่าสีในรูปแบบ int 
      'image': image,
      'markerId': markerId,
      'typeId': typeId,
    }; 
  }
}