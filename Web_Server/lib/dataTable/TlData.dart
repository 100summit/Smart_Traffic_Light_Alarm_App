import 'package:flutter/material.dart';

class TlData extends DataTableSource {
  List<Map<String, dynamic>> data;

  TlData({required this.data});

  @override
  DataRow? getRow(int index) {
    return DataRow(cells: [
      DataCell(Center(child: Text(data[index]['id'].toString()))),
      DataCell(Center(child: Text(data[index]['lat_lang'].toString()))),
      DataCell(Center(child: Text(data[index]['jk_count'].toString()))),
      DataCell(Center(child: Text(data[index]['z_count'].toString()))),
      DataCell(Center(child: Text(data[index]['t_count'].toString()))),
      DataCell(Center(child: Text(data[index]['w_count'].toString()))),
      DataCell(Center(child: Text(data[index]['c_count'].toString()))),
      DataCell(Center(child: Text(data[index]['p_count'].toString()))),
      DataCell(Center(child: Text(data[index]['d_count'].toString()))),
      DataCell(Center(child: Text(data[index]['av_time'].toString()))),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => 0;

  final Widget _verticalDivider = const VerticalDivider(
    color: Colors.black,
    thickness: 1,
  );
}
