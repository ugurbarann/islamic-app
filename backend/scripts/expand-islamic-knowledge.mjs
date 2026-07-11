import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const scriptDir = path.dirname(fileURLToPath(import.meta.url));
const filePath = path.resolve(
  scriptDir,
  "..",
  "..",
  "assets",
  "data",
  "islamic_knowledge_sample.json",
);
const data = JSON.parse(fs.readFileSync(filePath, "utf8"));

const builders = {
  daily: buildDaily,
  prophets: buildProphet,
  sahaba: buildCompanion,
  history: buildHistory,
  asmaul_husna: buildAsmaulHusna,
};

for (const category of data.categories) {
  const builder = builders[category.id];
  if (!builder) throw new Error(`Unknown category: ${category.id}`);
  category.articles = category.articles.map((article, index) => ({
    ...article,
    body: builder(article, index),
  }));
}

fs.writeFileSync(filePath, `${JSON.stringify(data, null, 2)}\n`, "utf8");
console.log(
  `Expanded ${data.categories.flatMap((category) => category.articles).length} articles.`,
);

function buildDaily(article, index) {
  const practices = [
    "Bu konuyu hayata taşımak için önce küçük ve sürdürülebilir bir adım belirlemek gerekir. Günün başında niyeti tazelemek, akşam olduğunda davranışları kısaca gözden geçirmek ve kırılan bir kalp varsa geciktirmeden telafi etmeye çalışmak iyi bir başlangıçtır.",
    "Bilgi ancak davranışa dönüştüğünde kalıcı bir eğitim hâline gelir. Bu sebeple insan, bir hafta boyunca bu ahlakı özellikle takip edebilir; acele ettiği, öfkelendiği veya çıkarıyla karşı karşıya kaldığı anlarda nasıl davrandığını dürüstçe değerlendirebilir.",
    "Günlük hayatın yoğunluğu güzel ilkeleri unutturabilir. Hatırlatıcı bir not koymak, aile içinde bu konu üzerine konuşmak ve her gün yalnız bir davranışı bilinçli biçimde düzeltmek, teorik bilgiyi yaşayan bir ahlaka dönüştürür.",
  ];
  return `${article.title}, İslam ahlakının yalnız sözde bırakılmaması gereken temel konularından biridir. ${article.summary} Bu ilke, insanın Rabbiyle bağını güçlendirdiği gibi ailesiyle, komşularıyla ve toplumla kurduğu ilişkiye de yön verir.

${article.body} Buradaki asıl ölçü, davranışın alışkanlıkla ve gösteriş için değil, bilinçli bir kulluk niyetiyle yapılmasıdır. İyi bir davranışın değeri yalnız görünen sonucunda değil; niyette, kullanılan dilde ve başkasının hakkını gözetme biçiminde de ortaya çıkar.

Kur'an ve sünnet, güzel ahlakı ibadetten ayrı bir alan olarak görmez. Namaz, dua ve zikir kalbi eğitirken bu eğitimin doğruluk, merhamet, sabır ve güvenilirlik olarak insan ilişkilerine yansıması beklenir. Kişi kendisini yalnız rahat zamanlarda değil, öfkelendiğinde, yorulduğunda ve menfaatiyle sınandığında da değerlendirmelidir.

${practices[index % practices.length]}

${article.title} konusunda dengeli olmak da önemlidir. İnsan kendi kusurunu görmeden başkasına öğüt vermemeli, bir hatayı düzeltirken kırıcı ve üstünlük taslayan bir dil kullanmamalıdır. Samimi bir tövbe, helallik isteme ve yeniden deneme iradesi, kusursuz görünmeye çalışmaktan daha değerlidir.

Sonuç olarak ${article.title.toLocaleLowerCase("tr-TR")}, bir defada tamamlanan bir görev değil, tekrar tekrar güçlendirilen bir kulluk eğitimidir. Küçük fakat devamlı adımlar, insanın karakterini dönüştürür; kalpteki niyet ile günlük davranış arasındaki mesafeyi azaltır.`;
}

function buildProphet(article, index) {
  const lessons = [
    "Kıssanın merkezinde iman ile davranışın birbirinden ayrılmaması vardır. Peygamberler yalnız doğruyu söylememiş, baskı ve zorluk karşısında o doğrunun gereğini yaşamışlardır. Bu yönüyle kıssa, sonuç hemen görünmese bile doğru çizgide kalmanın değerini öğretir.",
    "Bu hayatı okurken dikkat çeken husus, peygamberlerin insanları zorla değil açık delil, güzel öğüt ve sabırla hakka çağırmalarıdır. Tebliğ vazifesi yapılırken netlik korunmuş; buna karşılık hidayetin Allah'ın takdirinde olduğu bilinci kaybedilmemiştir.",
    "Kıssa aynı zamanda nimetin ve sıkıntının iki ayrı imtihan olduğunu gösterir. İmkân verildiğinde şükür ve adalet, zorluk geldiğinde sabır ve dua öne çıkar. Müminin görevi şartlara göre ilkesini değiştirmek değil, her şartta kulluk dengesini korumaktır.",
  ];
  return `${article.title}, Kur'an'da adı veya mücadelesi anılan peygamberlerdendir. Peygamber kıssaları salt bir tarih anlatısı değildir; tevhid, sorumluluk, ahlak ve insanın Allah karşısındaki konumu üzerine düşünmek için aktarılır. Bu nedenle kıssayı okurken olayların yanında verilen mesaja da dikkat etmek gerekir.

${article.body} Bu kısa çerçeve, onun tebliğinde öne çıkan yönü gösterir. Kur'an'ın ayrıntı vermediği noktaları kesin bilgiler gibi doldurmak yerine, açıkça bildirilen hakikatlerle yetinmek daha sağlıklı ve ilmî bir tutumdur.

${lessons[index % lessons.length]}

${article.title} üzerinden bugüne taşınabilecek en önemli derslerden biri, insanın sorumluluğunu şartlara bağlamamasıdır. Ailede, işte ve toplum içinde doğruyu savunmak; bunu yaparken adaletten, merhametten ve ölçülü dilden ayrılmamak gerekir. Sabır, hiçbir şey yapmadan beklemek değil, doğru yöntemi koruyarak gayrete devam etmektir.

Peygamberleri örnek almak, onların hayatını yalnız hayranlıkla okumak değildir. Kişi kendi putlaştırdığı arzuları, korkuları ve menfaatleri fark etmeli; duasını, kararlarını ve insanlarla ilişkisini tevhid bilinciyle yeniden düzenlemelidir. Hata edildiğinde dönüş kapısının açık olduğunu bilmeli, başarı geldiğinde ise bunu kendi üstünlüğüne değil Allah'ın lütfuna bağlamalıdır.

Sonuç olarak ${article.title} kıssası, geçmişte kalmış tek bir olaydan çok daha fazlasıdır. Kur'an'ın çizdiği sınırlar içinde okunduğunda insanı ümitsizlikten korur, sorumluluğa çağırır ve kulluğun sabır, güven, dua ve güzel ahlakla birlikte yürüdüğünü hatırlatır.`;
}

function buildCompanion(article, index) {
  const perspectives = [
    "Sahabe neslinin değeri, hatasız insanlar olmalarından değil; vahyin eğitimine samimiyetle açılmaları, yanlışlarını düzeltebilmeleri ve inandıkları değerler uğruna ciddi bedeller üstlenmelerinden gelir.",
    "Onların hayatlarını değerlendirirken yalnız olağanüstü görünen olaylara odaklanmak eksik olur. Aile ilişkileri, ilim öğrenme gayreti, infak, istişare ve toplumsal sorumluluk gibi günlük alanlar da bu neslin örnekliğini anlamak için önemlidir.",
    "Sahabiler farklı karakterlere, imkânlara ve yeteneklere sahipti. Kimi ilimde, kimi yönetimde, kimi hizmette, kimi de fedakârlıkta öne çıktı. Bu çeşitlilik, hayra hizmet etmenin tek bir biçime indirgenemeyeceğini gösterir.",
  ];
  return `${article.title}, Hz. Peygamber'in eğitiminden geçen sahabe neslinin dikkat çeken isimlerinden biridir. Onun hayatını anlamak, yalnız birkaç meşhur olayı ezberlemek değil; imanının kararlarına, ahlakına ve sorumluluk anlayışına nasıl yön verdiğini görmeye çalışmaktır.

${article.body} Bu özellikler, onun yaşadığı dönemde üstlendiği sorumlulukların hangi ahlaki zemine dayandığını gösterir. Siyer ve tabakat kaynaklarında aktarılan bilgiler değerlendirilirken sağlam rivayet ile sonradan yaygınlaşmış menkıbeleri birbirinden ayırmak gerekir.

${perspectives[index % perspectives.length]}

${article.title} örneğinden bugüne taşınabilecek ders, kişinin sahip olduğu imkânı hayırlı bir sorumluluğa dönüştürmesidir. Bilgi, servet, makam, gençlik veya meslek tek başına üstünlük sebebi değildir. Bunların değeri; adalet, dürüstlük, hizmet ve Allah rızası için kullanıldığında ortaya çıkar.

Bu hayatı okumak kişinin kendisine bazı sorular sormasını sağlar: Zor bir anda doğru bildiğimin yanında durabiliyor muyum? İmkânımı paylaşabiliyor, eleştirildiğimde nefsimi savunmak yerine gerçeği arayabiliyor muyum? İnsanlara karşı güvenilir ve merhametli miyim? Örnek şahsiyetleri sevmek, bu soruları davranışa dönüştüren bir muhasebeyi gerektirir.

Sonuç olarak ${article.title}, erişilmez bir kahraman olarak değil, vahyin insan karakterini nasıl inşa ettiğini gösteren canlı bir örnek olarak okunmalıdır. Onun hayatından alınacak pay; samimiyeti artırmak, sorumluluktan kaçmamak ve iyi niyeti doğru yöntemle birleştirmektir.`;
}

function buildHistory(article, index) {
  const methods = [
    "Bu hadise sebep, süreç ve sonuçları birlikte ele alındığında daha doğru anlaşılır. Yalnız sonucu öne çıkarmak; hazırlık, istişare, insan emeği ve ahlaki tercihleri görünmez hâle getirebilir.",
    "Tarihî olayları bugünün kavramlarıyla aceleci biçimde yargılamak kadar, geçmişi bütünüyle kusursuzlaştırmak da sağlıklı değildir. Siyer kaynakları karşılaştırılmalı; kesin bilgi, güçlü rivayet ve yorum birbirinden ayrılmalıdır.",
    "Olayın en öğretici tarafı, Müslüman toplumun karşılaştığı problemi yalnız temenniyle değil; planlama, dayanışma, sabır ve gerektiğinde yeni yöntemler geliştirerek aşmaya çalışmasıdır.",
  ];
  return `${article.title}, İslam tarihinin oluşumunu ve Müslüman toplumun hangi ilkeler etrafında şekillendiğini anlamak bakımından önemli bir başlıktır. Tarih, yalnız tarihler ve isimler listesi değildir; kararların sebeplerini, sonuçlarını ve insan üzerindeki etkisini birlikte değerlendirme alanıdır.

${article.body} Bu olayın önemi, sadece yaşandığı dönemdeki sonucu ile sınırlı değildir. Adalet, emanet, istişare, kardeşlik ve toplumsal sorumluluk gibi ilkelerin gerçek şartlar altında nasıl sınandığını da gösterir.

${methods[index % methods.length]}

${article.title} bugünün insanına da önemli sorular yöneltir: Kriz zamanında ortak akıl üretebiliyor muyuz? Güç elde ettiğimizde adaleti koruyor muyuz? Kısa vadeli kazanç yerine uzun vadeli iyiliği gözetebiliyor muyuz? Tarihten ders almak, eski olayları bugünkü tartışmalara slogan yapmak değil, benzer ahlaki sınavlarda daha bilinçli davranmaktır.

Bu konuyu okurken farklı güvenilir siyer ve tarih çalışmalarına başvurmak, tek bir anlatıdaki ayrıntıyı mutlaklaştırmamak gerekir. Özellikle kişi ve topluluklar hakkında hüküm verirken dönemin şartları, kaynakların aktarım yöntemi ve rivayetlerin güvenilirliği hesaba katılmalıdır. Böyle bir okuma hem sevgiyi hem ilmî ciddiyeti korur.

Sonuç olarak ${article.title}, Müslümanların karşılaştıkları meseleleri iman, akıl, ahlak ve ortak sorumlulukla çözme çabasını gösteren bir tecrübedir. Olayın kalıcı değeri, geçmişe duyulan övgüden çok bugünün davranışını daha adil, ölçülü ve sorumlu hâle getirmesinde ortaya çıkar.`;
}

function buildAsmaulHusna(article, index) {
  const reflections = [
    "Bir ismi öğrenirken yalnız Türkçe karşılığını ezberlemek yeterli değildir. İsmin Kur'an'daki kullanımını, başka isimlerle ilişkisini ve kulda uyandırması gereken dua ile sorumluluk bilincini birlikte düşünmek gerekir.",
    "Tefekkürün amacı Allah'ın zatı hakkında sınırı aşan tasavvurlar üretmek değil, vahyin bildirdiği isim ve sıfatlar üzerinden imanı derinleştirmektir. Bilgi, hayranlık ve kullukla sonuçlanmalıdır.",
    "İsimlerin hayata yansıması, kulun ilahi sıfatları kendisine mal etmesi anlamına gelmez. İnsan, kulluk sınırları içinde merhametli, adil, bağışlayıcı ve güvenilir olmaya çalışarak bu bilgiden ahlaki bir pay alır.",
  ];
  return `${article.title}, Allah'ı O'nun kendisini tanıttığı güzel isimler üzerinden anlama ve anma çabasının bir parçasıdır. Kur'an, en güzel isimlerin Allah'a ait olduğunu bildirir ve kulları bu isimlerle dua etmeye yöneltir. Bu bilgi, kuru bir ezber değil, iman ve kulluk bilinci oluşturmalıdır.

${article.body} Her isim, Allah'ın rahmeti, ilmi, kudreti, hikmeti veya adaleti hakkında insana bir tefekkür kapısı açar. Fakat hiçbir tercüme bir ismin bütün anlam genişliğini tek kelimeyle kuşatamaz; bu nedenle güvenilir açıklamalardan yararlanmak önemlidir.

${reflections[index % reflections.length]}

Esmaül Hüsna ile dua ederken ihtiyaç ile ismin anlamı arasında bağ kurulabilir. Bağışlanma isteyen kul El-Gafûr'u, merhamet dileyen kul Er-Rahmân ve Er-Rahîm'i, doğru karar için yardım isteyen kul El-Hakîm'i anabilir. Burada amaç bir formülü tekrarlamak değil, kimin huzurunda dua edildiğinin farkında olmaktır.

Günlük bir çalışma için her hafta bir isim seçilebilir. İsmin anlamı güvenilir bir kaynaktan okunur, Kur'an'daki kullanımları incelenir ve bu bilginin kişinin duasına ve ahlakına ne kattığı not edilir. Böylece ezber, düşünceye; düşünce de daha bilinçli bir kulluğa dönüşür.

Sonuç olarak ${article.title.toLocaleLowerCase("tr-TR")}, Allah hakkındaki bilgiyi çoğaltırken insanın aczini ve sorumluluğunu da hatırlatır. Doğru tefekkür kalpte ümit ve saygıyı birlikte büyütür; kişiyi dua etmeye, şükretmeye ve insanlara karşı daha güzel davranmaya yöneltir.`;
}
