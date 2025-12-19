import 'package:input_quantity/input_quantity.dart';
import 'package:flutter/material.dart';

class ProcessCard extends StatefulWidget {
  ProcessCard({
    super.key,
    required this.processId,
    this.cardColor = Colors.blue,
  });

  final int processId;
  num _offset = 0;      // Init Time
  num _computation = 1; // C
  num _period = 5;      // T
  Color cardColor;

  int getOffset() => _offset.toInt();
  int getComputation() => _computation.toInt();
  int getPeriod() => _period.toInt();

  @override
  State<ProcessCard> createState() => _ProcessCard();
}

class _ProcessCard extends State<ProcessCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        height: 100, // Altura reduzida fixada
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            // ID Badge
            Container(
              width: 60,
              decoration: BoxDecoration(
                color: widget.cardColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: widget.cardColor, width: 2)
              ),
              child: Center(
                child: Text(
                  "P${widget.processId}",
                  style: TextStyle(
                    fontSize: 20, 
                    fontWeight: FontWeight.bold, 
                    color: widget.cardColor
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Inputs
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildInput("Comp. (C)", widget._computation, (val) => widget._computation = val),
                  _buildInput("Period (T)", widget._period, (val) => widget._period = val),
                  _buildInput("Offset (O)", widget._offset, (val) => widget._offset = val, min: 0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(String label, num initVal, Function(num) onChanged, {num min = 1}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 4),
        SizedBox(
          width: 90,
          child: InputQty(
            maxVal: 100,
            minVal: min,
            initVal: initVal,
            showMessageLimit: false,
            btnColor1: Colors.grey,
            onQtyChanged: (val) => setState(() => onChanged(val)),
          ),
        ),
      ],
    );
  }
}