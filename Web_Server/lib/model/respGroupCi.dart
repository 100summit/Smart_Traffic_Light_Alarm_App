import 'package:flutter_mobius/model/conci.dart';

class respGroupCi {
  M2mAgr? m2mAgr;

  respGroupCi({this.m2mAgr});

  respGroupCi.fromJson(Map<String, dynamic> json) {
    m2mAgr = json['m2m:agr'] != null ? M2mAgr.fromJson(json['m2m:agr']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (m2mAgr != null) {
      data['m2m:agr'] = m2mAgr!.toJson();
    }
    return data;
  }
}

class M2mAgr {
  List<M2mRsps>? m2mRsp;

  M2mAgr({this.m2mRsp});

  M2mAgr.fromJson(Map<String, dynamic> json) {
    if (json['m2m:rsp'] != null) {
      m2mRsp = <M2mRsps>[];
      json['m2m:rsp'].forEach((v) {
        m2mRsp!.add(M2mRsps.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (m2mRsp != null) {
      data['m2m:rsp'] = m2mRsp!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class M2mRsps {
  String? fr;
  String? rsc;
  String? rqi;
  String? rvi;
  Pc? pc;

  M2mRsps({this.fr, this.rsc, this.rqi, this.rvi, this.pc});

  M2mRsps.fromJson(Map<String, dynamic> json) {
    fr = json['fr'];
    rsc = json['rsc'];
    rqi = json['rqi'];
    rvi = json['rvi'];
    pc = json['pc'] != null ? Pc.fromJson(json['pc']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['fr'] = fr;
    data['rsc'] = rsc;
    data['rqi'] = rqi;
    data['rvi'] = rvi;
    if (pc != null) {
      data['pc'] = pc!.toJson();
    }
    return data;
  }
}

class Pc {
  M2mRsp? m2mRsp;

  Pc({this.m2mRsp});

  Pc.fromJson(Map<String, dynamic> json) {
    m2mRsp = json['m2m:rsp'] != null ? M2mRsp.fromJson(json['m2m:rsp']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (m2mRsp != null) {
      data['m2m:rsp'] = m2mRsp!.toJson();
    }
    return data;
  }
}

class M2mRsp {
  List<M2mCin>? m2mCin;

  M2mRsp({this.m2mCin});

  M2mRsp.fromJson(Map<String, dynamic> json) {
    if (json['m2m:cin'] != null) {
      m2mCin = <M2mCin>[];
      json['m2m:cin'].forEach((v) {
        m2mCin!.add(M2mCin.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (m2mCin != null) {
      data['m2m:cin'] = m2mCin!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class M2mCin {
  String? pi;
  String? ri;
  int? ty;
  String? ct;
  int? st;
  String? rn;
  String? lt;
  String? et;
  int? cs;
  String? cr;
  ConCi? con;

  M2mCin(
      {this.pi,
      this.ri,
      this.ty,
      this.ct,
      this.st,
      this.rn,
      this.lt,
      this.et,
      this.cs,
      this.cr,
      this.con});

  M2mCin.fromJson(Map<String, dynamic> json) {
    pi = json['pi'];
    ri = json['ri'];
    ty = json['ty'];
    ct = json['ct'];
    st = json['st'];
    rn = json['rn'];
    lt = json['lt'];
    et = json['et'];
    cs = json['cs'];
    cr = json['cr'];
    con = json['con'] != null ? ConCi.fromJson(json['con']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['pi'] = pi;
    data['ri'] = ri;
    data['ty'] = ty;
    data['ct'] = ct;
    data['st'] = st;
    data['rn'] = rn;
    data['lt'] = lt;
    data['et'] = et;
    data['cs'] = cs;
    data['cr'] = cr;
    if (con != null) {
      data['con'] = con!.toJson();
    }
    return data;
  }
}
