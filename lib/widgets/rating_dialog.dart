import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:hr_app/managers/firebaseHelper.dart';

class RatingDialog extends StatefulWidget {
  final Map<String, dynamic> doc;

  const RatingDialog({super.key, required this.doc});
  @override
  _RatingDialogState createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  final FirestoreManager _firestoreManager = FirestoreManager();
  double _rating1 = 0;
  double _rating2 = 0;
  double _rating3 = 0;
  double _rating4 = 0;
  double _rating5 = 0;
  double _rating6 = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  double averageRating = 0;
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: const Text(
          'تقيم الموظف',
          style: TextStyle(fontSize: 20),
        ),
        contentPadding: const EdgeInsets.all(24),
        content: SingleChildScrollView(
          child: Container(
            width: screenHeight * 0.5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                buildRatingBar("تقيم اخلاقي", _rating1, (rating) {
                  setState(() {
                    _rating1 = rating;
                    averageRating = calculateAverageRating();
                  });
                }),
                buildRatingBar("الالتزام بالتعليمات", _rating2, (rating) {
                  setState(() {
                    _rating2 = rating;
                    averageRating = calculateAverageRating();
                  });
                }),
                buildRatingBar("تقيم الاداء", _rating3, (rating) {
                  setState(() {
                    _rating3 = rating;
                    averageRating = calculateAverageRating();
                  });
                }),
                buildRatingBar("العمل مع الفريق", _rating4, (rating) {
                  setState(() {
                    _rating4 = rating;
                    averageRating = calculateAverageRating();
                  });
                }),
                buildRatingBar("التزام المواعيد", _rating5, (rating) {
                  setState(() {
                    _rating5 = rating;
                    averageRating = calculateAverageRating();
                  });
                }),
                buildRatingBar("الحرص علي مقدرات الشركه", _rating6, (rating) {
                  setState(() {
                    _rating6 = rating;
                    averageRating = calculateAverageRating();
                  });
                }),
                const SizedBox(height: 20),
                const Text(
                  'التقيم الشامل للموظف',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                RatingBar.builder(
                  initialRating: averageRating,
                  minRating: 0,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemSize: 50,
                  itemCount: 5,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 36,
                  ),
                  onRatingUpdate: (rating) {
                    // This rating is not updatable, it just shows the average
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              _firestoreManager.updateDocument(
                  "الموظفين", widget.doc['name'], {"rate": averageRating});
              // You can handle the logic here when the user confirms the ratings
              Navigator.of(context).pop();
            },
            child: const Text('تعديل تقيم الموظف'),
          ),
        ],
      ),
    );
  }

  Widget buildRatingBar(
      String label, double rating, Function(double) onRatingChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 18),
        ),
        RatingBar.builder(
          initialRating: rating,
          minRating: 0,
          direction: Axis.horizontal,
          allowHalfRating: true,
          itemCount: 5,
          itemPadding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4),
          itemSize: 50,
          itemBuilder: (context, _) => const Icon(
            Icons.star,
            color: Colors.amber,
            size: 36,
          ),
          onRatingUpdate: onRatingChanged,
        ),
      ],
    );
  }

  double calculateAverageRating() {
    return (_rating1 + _rating2 + _rating3 + _rating4 + _rating5 + _rating6) /
        6;
  }
}
