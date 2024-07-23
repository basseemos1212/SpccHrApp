class Employee {
  final String name;
  final String number;
  final String image;
  final String job;
  final String department;
  final String enterDate;
  final String endDate;
  final String vacationsTime;
  final String status;
  final double rate;
  final double salary;
  final String nationality;
  final String relegion;
  final String vacations;
  final Map<String, dynamic> salaryAlternatives;
  final String workStatus;
  final String finalJobPrize;
  final String workLocation;

  Employee(
      {required this.name,
      required this.department,
      required this.enterDate,
      required this.endDate,
      required this.vacationsTime,
      required this.number,
      required this.image,
      required this.job,
      required this.status,
      required this.rate,
      required this.salary,
      required this.nationality,
      required this.relegion,
      required this.vacations,
      required this.salaryAlternatives,
      required this.workStatus,
      required this.finalJobPrize,
      required this.workLocation});
}
