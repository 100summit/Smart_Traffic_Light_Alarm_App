class Con {
  String? id;
  int? jkCount = 0;
  int? avTime = 0;
  int? j0003 = 0;
  int? j0306 = 0;
  int? j0609 = 0;
  int? j0912 = 0;
  int? j1215 = 0;
  int? j1518 = 0;
  int? j1821 = 0;
  int? j2124 = 0;
  int? t0003 = 0;
  int? t0306 = 0;
  int? t0609 = 0;
  int? t0912 = 0;
  int? t1215 = 0;
  int? t1518 = 0;
  int? t1821 = 0;
  int? t2124 = 0;
  double? lat = 0.0;
  double? lang = 0.0;
  int? weakCount = 0;
  int? chiCount = 0;
  int? preCount = 0;
  int? disCount = 0;

  Con(
      {this.id,
      this.jkCount,
      this.avTime,
      this.j0003,
      this.j0306,
      this.j0609,
      this.j0912,
      this.j1215,
      this.j1518,
      this.j1821,
      this.j2124,
      this.t0003,
      this.t0306,
      this.t0609,
      this.t0912,
      this.t1215,
      this.t1518,
      this.t1821,
      this.t2124,
      this.lat,
      this.lang,
      this.weakCount,
      this.chiCount,
      this.preCount,
      this.disCount});

  Con.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    jkCount = json['jk_count'];
    avTime = json['av_time'];
    j0003 = json['j_0003'];
    j0306 = json['j_0306'];
    j0609 = json['j_0609'];
    j0912 = json['j_0912'];
    j1215 = json['j_1215'];
    j1518 = json['j_1518'];
    j1821 = json['j_1821'];
    j2124 = json['j_2124'];
    t0003 = json['t_0003'];
    t0306 = json['t_0306'];
    t0609 = json['t_0609'];
    t0912 = json['t_0912'];
    t1215 = json['t_1215'];
    t1518 = json['t_1518'];
    t1821 = json['t_1821'];
    t2124 = json['t_2124'];
    lat = json['lat'];
    lang = json['lang'];
    weakCount = json['weak_count'];
    chiCount = json['chi_count'];
    preCount = json['pre_count'];
    disCount = json['dis_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['jk_count'] = jkCount;
    data['av_time'] = avTime;
    data['j_0003'] = j0003;
    data['j_0306'] = j0306;
    data['j_0609'] = j0609;
    data['j_0912'] = j0912;
    data['j_1215'] = j1215;
    data['j_1518'] = j1518;
    data['j_1821'] = j1821;
    data['j_2124'] = j2124;
    data['t_0003'] = t0003;
    data['t_0306'] = t0306;
    data['t_0609'] = t0609;
    data['t_0912'] = t0912;
    data['t_1215'] = t1215;
    data['t_1518'] = t1518;
    data['t_1821'] = t1821;
    data['t_2124'] = t2124;
    data['lat'] = lat;
    data['lang'] = lang;
    data['weak_count'] = weakCount;
    data['chi_count'] = chiCount;
    data['pre_count'] = preCount;
    data['dis_count'] = disCount;
    return data;
  }
}
