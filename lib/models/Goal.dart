class Goal {
  String id;
  String title;
  DateTime creationDate;
  DateTime startDate;
  DateTime endDate;

  Goal({
    this.id,
    this.title,
    this.creationDate,
    this.startDate,
    this.endDate,
  });

  Goal.fromJson(Map<String, dynamic> jsonObject) {
    this.id = jsonObject['id'];
    this.title = jsonObject['title'];
    this.creationDate = jsonObject['creationDate'];
    this.startDate = jsonObject['startDate'];
    this.endDate = jsonObject['endDate'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'creationDate': creationDate,
      'startDate': startDate,
      'endDate': endDate,
    };
  }
}
