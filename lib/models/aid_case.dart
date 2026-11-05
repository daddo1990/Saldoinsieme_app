class AidCase {
  const AidCase({required this.id,required this.slug,required this.category,required this.title,
   required this.story,required this.goalCents,required this.fundedCents,
   required this.status,required this.isDemo,required this.verified,this.dueDate});
  final int id,goalCents,fundedCents;
  final String slug,category,title,story,status;
  final bool isDemo,verified;
  final DateTime? dueDate;
  factory AidCase.fromJson(Map<String,dynamic> x)=>AidCase(
   id:(x['id'] as num).toInt(),slug:x['slug'] as String? ?? '',
   category:x['category'] as String? ?? 'altro',title:x['title'] as String? ?? '',
   story:x['story'] as String? ?? '',goalCents:(x['goal_cents'] as num?)?.toInt() ?? 0,
   fundedCents:(x['funded_cents'] as num?)?.toInt() ?? 0,
   status:x['status'] as String? ?? 'draft',isDemo:x['is_demo']==true,
   verified:x['verified']==true,
   dueDate:DateTime.tryParse(x['due_date'] as String? ?? ''));
  double get progress=>goalCents<=0?0:(fundedCents/goalCents).clamp(0,1).toDouble();
  static const examples=<AidCase>[
   AidCase(id:-1,slug:'demo-luce',category:'bollette',title:'Una bolletta della luce da affrontare',story:'Una famiglia cerca di affrontare una spesa imprevista. Questa storia è completamente inventata e serve soltanto per mostrare il funzionamento della piattaforma. Nessun contributo reale viene raccolto.',goalCents:18600,fundedCents:0,status:'published',isDemo:true,verified:false),
   AidCase(id:-2,slug:'demo-affitto',category:'affitto',title:'Un mese di affitto, un po’ di respiro',story:'Questa è una richiesta di esempio per una spesa abitativa, senza alcun beneficiario reale. La piattaforma è in anteprima e non sono abilitati pagamenti.',goalCents:62000,fundedCents:0,status:'published',isDemo:true,verified:false),
   AidCase(id:-3,slug:'demo-scuola',category:'scuola',title:'Libri e materiali per ripartire insieme',story:'Una storia fittizia che rappresenta una possibile richiesta per spese scolastiche. Serve a valutare il design e simulare il totale comprensivo della commissione di servizio.',goalCents:24500,fundedCents:0,status:'published',isDemo:true,verified:false)
  ];
}
const categoryLabels=<String,String>{'all':'Tutte','bollette':'Bollette','affitto':'Affitto','debiti':'Debiti','salute':'Salute','scuola':'Scuola','emergenze':'Emergenze','altro':'Altro'};
String categoryLabel(String value)=>categoryLabels[value]??'Altro';
int serviceFeeCents(int amount)=>(amount+19)~/20;
int totalCents(int amount)=>amount+serviceFeeCents(amount);
String euro(int cents){
 final a=cents.abs(),whole=(a~/100).toString(),negative=cents<0?'-':'';
 final grouped=whole.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'),(m)=>'.');
 return negative+'€ '+grouped+','+(a%100).toString().padLeft(2,'0');
}
