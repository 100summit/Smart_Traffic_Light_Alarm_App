import 'package:flutter_mobius/model/con2.dart';

class respTlState {
  M2mCin? m2mCin;

  respTlState({this.m2mCin});

  respTlState.fromJson(Map<String, dynamic> json) {
    m2mCin = json['m2m:cin'] != null ? M2mCin.fromJson(json['m2m:cin']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (m2mCin != null) {
      data['m2m:cin'] = m2mCin!.toJson();
    }
    return data;
  }
}

class M2mCin {
  String? rn;
  int? ty;
  String? pi;
  String? ri;
  String? ct;
  String? lt;
  int? st;
  String? et;
  int? cs;
  Con2? con;
  String? cr;

  M2mCin(
      {this.rn,
      this.ty,
      this.pi,
      this.ri,
      this.ct,
      this.lt,
      this.st,
      this.et,
      this.cs,
      this.con,
      this.cr});

  M2mCin.fromJson(Map<String, dynamic> json) {
    rn = json['rn'];
    ty = json['ty'];
    pi = json['pi'];
    ri = json['ri'];
    ct = json['ct'];
    lt = json['lt'];
    st = json['st'];
    et = json['et'];
    cs = json['cs'];
    con = json['con'] != null ? Con2.fromJson(json['con']) : null;
    cr = json['cr'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['rn'] = rn;
    data['ty'] = ty;
    data['pi'] = pi;
    data['ri'] = ri;
    data['ct'] = ct;
    data['lt'] = lt;
    data['st'] = st;
    data['et'] = et;
    data['cs'] = cs;
    if (con != null) {
      data['con'] = con!.toJson();
    }
    data['cr'] = cr;
    return data;
  }
}
