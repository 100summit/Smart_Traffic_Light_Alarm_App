import 'package:flutter_mobius/model/con.dart';

class reqTlInfo {
  M2mCins? m2mCin;

  reqTlInfo({this.m2mCin});

  reqTlInfo.fromJson(Map<String, dynamic> json) {
    m2mCin = json['m2m:cin'] != null ? M2mCins.fromJson(json['m2m:cin']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (m2mCin != null) {
      data['m2m:cin'] = m2mCin!.toJson();
    }
    return data;
  }
}

class M2mCins {
  Con? con;

  M2mCins({this.con});

  M2mCins.fromJson(Map<String, dynamic> json) {
    con = json['con'] != null ? Con.fromJson(json['con']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (con != null) {
      data['con'] = con!.toJson();
    }
    return data;
  }
}
