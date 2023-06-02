import 'package:flutter_mobius/model/con2.dart';

class reqTlState {
  M2mCin2? m2mCin;

  reqTlState({this.m2mCin});

  reqTlState.fromJson(Map<String, dynamic> json) {
    m2mCin = json['m2m:cin'] != null ? M2mCin2.fromJson(json['m2m:cin']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (m2mCin != null) {
      data['m2m:cin'] = m2mCin!.toJson();
    }
    return data;
  }
}

class M2mCin2 {
  Con2? con;

  M2mCin2({this.con});

  M2mCin2.fromJson(Map<String, dynamic> json) {
    con = json['con'] != null ? Con2.fromJson(json['con']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (con != null) {
      data['con'] = con!.toJson();
    }
    return data;
  }
}
