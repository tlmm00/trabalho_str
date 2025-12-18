import 'package:input_quantity/input_quantity.dart';
import 'package:flutter/material.dart';

class ProcessCard extends StatefulWidget {
  ProcessCard({
    super.key,
    required this.processId,
    this.cardColor = Colors.blue,
  });

  final int processId;
  num _initTime = 0;
  num _ttf = 1;
  num _deadline = 0;
  Color cardColor;

  num getInitTime() {
    return _initTime;
  }

  num getTtf() {
    return _ttf;
  }

  num getDeadline() {
    return _deadline;
  }

  void setInitTime(num newInitTime) {
    _initTime = newInitTime;
  }

  void setTtf(num newTtf) {
    if (newTtf > 0) {
      _ttf = newTtf;
    } else {
      _ttf = 1;
    }
  }

  void setDeadline(num newDeadline) {
    _deadline = newDeadline;
  }

  @override
  State<ProcessCard> createState() => _ProcessCard();
}

class _ProcessCard extends State<ProcessCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 400,
        height: 350,
        decoration: BoxDecoration(border: Border.all(color: Colors.black)),
        child: Center(
          child: Container(
            color: widget.cardColor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(50.0),
                  child: Text(
                    "#${widget.processId.toString()}",
                    style: const TextStyle(
                        fontSize: 50, fontWeight: FontWeight.bold),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Init Time: ",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          InputQty(
                            minVal: 0,
                            initVal: widget.getInitTime(),
                            onQtyChanged: (value) => {
                              setState(() => widget.setInitTime(value.toInt()))
                            },
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Deadline: ",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          InputQty(
                            minVal: 0,
                            initVal: widget.getDeadline(),
                            onQtyChanged: (value) => {
                              setState(() => widget.setDeadline(value.toInt()))
                            },
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Time to Finish: ",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          InputQty(
                            minVal: 1,
                            initVal: widget.getTtf(),
                            onQtyChanged: (value) =>
                                {setState(() => widget.setTtf(value.toInt()))},
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ));
  }
}
