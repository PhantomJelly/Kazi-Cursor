import 'package:kazi/shared/constants/trade_categories.dart';

class DemoCertification {
  const DemoCertification({
    required this.title,
    required this.issuer,
  });

  final String title;
  final String issuer;
}

class DemoWorker {
  const DemoWorker({
    required this.name,
    required this.town,
    required this.country,
    required this.trade,
    required this.experience,
    required this.photoUrl,
    required this.bio,
    this.certifications = const [],
    this.email = '',
    this.phone = '',
    this.whatsapp = '',
  });

  final String name;
  final String town;
  final String country;
  final TradeCategory trade;
  final String experience;
  final String photoUrl;
  final String bio;
  final List<DemoCertification> certifications;
  final String email;
  final String phone;
  final String whatsapp;

  String get id => email;

  bool get isCertified => certifications.isNotEmpty;

  String get heroTag => photoUrl;

  List<String> get portfolioPhotoUrls {
    final seed = Uri.encodeComponent(id);
    return [
      'https://picsum.photos/seed/${seed}a/600/600',
      'https://picsum.photos/seed/${seed}b/600/600',
      'https://picsum.photos/seed/${seed}c/600/600',
      'https://picsum.photos/seed/${seed}d/600/600',
    ];
  }
}

DemoWorker? demoWorkerById(String id) {
  for (final worker in demoWorkers) {
    if (worker.id == id) return worker;
  }
  return null;
}

const demoWorkers = [
  DemoWorker(
    name: 'Andreas Shilongo',
    town: 'Windhoek',
    country: 'Namibia',
    trade: TradeCategory.plumber,
    experience: '5–10 years',
    photoUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
    email: 'andreas.shilongo@kazi.na',
    phone: '081 234 5678',
    whatsapp: '081 234 5678',
    certifications: [
      DemoCertification(
        title: 'Plumbing Level 2',
        issuer: 'Namibia Training Authority',
      ),
      DemoCertification(
        title: 'Pipe Fitting Certificate',
        issuer: 'NIMT',
      ),
    ],
    bio:
        'I am a licensed plumber based in Windhoek with years of hands-on experience in residential and small commercial work. I handle leaking pipes, geyser installations, blocked drains, and bathroom renovations with care. I arrive on time, explain the job clearly, and leave the site clean so you can get back to your day with working water.',
  ),
  DemoWorker(
    name: 'Maria Nakale',
    town: 'Windhoek',
    country: 'Namibia',
    trade: TradeCategory.cleaner,
    experience: '2–5 years',
    photoUrl: 'https://randomuser.me/api/portraits/women/44.jpg',
    email: 'maria.nakale@kazi.na',
    phone: '081 345 6789',
    whatsapp: '081 345 6789',
    bio:
        'I provide thorough home and office cleaning across Windhoek. My work covers regular house cleaning, deep cleans, and move-in or move-out jobs. I bring my own supplies when needed, pay attention to kitchens and bathrooms, and treat every home with respect. Customers often ask me back because the space feels fresh and well looked after.',
  ),
  DemoWorker(
    name: 'Petrus Hangula',
    town: 'Swakopmund',
    country: 'Namibia',
    trade: TradeCategory.plumber,
    experience: '10+ years',
    photoUrl: 'https://randomuser.me/api/portraits/men/75.jpg',
    email: 'petrus.hangula@kazi.na',
    phone: '081 456 7890',
    whatsapp: '081 456 7890',
    certifications: [
      DemoCertification(
        title: 'Master Plumber',
        issuer: 'Namibia Training Authority',
      ),
    ],
    bio:
        'I have more than ten years of plumbing experience along the coast, from Swakopmund homes to guesthouses. I specialise in geyser repairs, outdoor taps, and salt-air pipe problems that need extra care. I give a clear quote before I start and I am available for urgent leaks when water cannot wait until the next day.',
  ),
  DemoWorker(
    name: 'Lina Hamutenya',
    town: 'Walvis Bay',
    country: 'Namibia',
    trade: TradeCategory.painter,
    experience: '1–2 years',
    photoUrl: 'https://randomuser.me/api/portraits/women/65.jpg',
    email: 'lina.hamutenya@kazi.na',
    phone: '081 567 8901',
    whatsapp: '081 567 8901',
    bio:
        'I paint interiors and exteriors in Walvis Bay, including walls, ceilings, and small commercial spaces. I help you choose colours, prepare surfaces properly, and protect furniture while I work. My finish is even and neat, and I clean up at the end of each day so your home stays liveable during the job.',
  ),
  DemoWorker(
    name: 'Johannes Negumbo',
    town: 'Oshakati',
    country: 'Namibia',
    trade: TradeCategory.handyman,
    experience: '2–5 years',
    photoUrl: 'https://randomuser.me/api/portraits/men/22.jpg',
    email: 'johannes.negumbo@kazi.na',
    phone: '081 678 9012',
    whatsapp: '081 678 9012',
    certifications: [
      DemoCertification(
        title: 'General Maintenance',
        issuer: 'NIMT',
      ),
    ],
    bio:
        'I am a handyman in Oshakati for the jobs that do not need a full specialist crew. I fix doors, shelves, basic electrics, leaking taps, and furniture assembly. I work carefully in occupied homes and I will tell you honestly if a task needs a licensed plumber or electrician instead of a quick repair.',
  ),
  DemoWorker(
    name: 'Selma Amadhila',
    town: 'Windhoek',
    country: 'Namibia',
    trade: TradeCategory.gardener,
    experience: '6 months – 1 year',
    photoUrl: 'https://randomuser.me/api/portraits/women/21.jpg',
    email: 'selma.amadhila@kazi.na',
    phone: '081 789 0123',
    whatsapp: '081 789 0123',
    bio:
        'I look after gardens in Windhoek with regular lawn cutting, weeding, watering, and hedge trimming. I can also help with simple planting and keeping outdoor areas tidy for weekend guests. I am reliable, I bring my own basic tools, and I work quietly so neighbours are not disturbed while your yard is being cared for.',
  ),
  DemoWorker(
    name: 'David Shikongo',
    town: 'Rundu',
    country: 'Namibia',
    trade: TradeCategory.carpenter,
    experience: '5–10 years',
    photoUrl: 'https://randomuser.me/api/portraits/men/52.jpg',
    email: 'david.shikongo@kazi.na',
    phone: '081 890 1234',
    whatsapp: '081 890 1234',
    bio:
        'I am a carpenter in Rundu building and repairing wooden furniture, doors, frames, and kitchen fittings. I measure twice, use solid timber where I can, and finish pieces so they last in a busy home. Whether you need a custom shelf or a broken table restored, I will discuss the design with you before cutting any wood.',
  ),
  DemoWorker(
    name: 'Helena Nangolo',
    town: 'Walvis Bay',
    country: 'Namibia',
    trade: TradeCategory.poolCleaner,
    experience: '2–5 years',
    photoUrl: 'https://randomuser.me/api/portraits/women/68.jpg',
    email: 'helena.nangolo@kazi.na',
    phone: '081 901 2345',
    whatsapp: '081 901 2345',
    bio:
        'I clean and maintain swimming pools in Walvis Bay so the water stays clear through wind and dust. My visits include skimming, vacuuming, checking chemicals, and wiping tiles. I can set up a weekly schedule for homes and small guesthouses, and I will flag pump or filter issues early before they become expensive repairs.',
  ),
  DemoWorker(
    name: 'Tomas Iipinge',
    town: 'Swakopmund',
    country: 'Namibia',
    trade: TradeCategory.welder,
    experience: '10+ years',
    photoUrl: 'https://randomuser.me/api/portraits/men/11.jpg',
    email: 'tomas.iipinge@kazi.na',
    phone: '081 012 3456',
    whatsapp: '081 012 3456',
    certifications: [
      DemoCertification(
        title: 'Coded Welder',
        issuer: 'Namibia Training Authority',
      ),
      DemoCertification(
        title: 'Metal Fabrication',
        issuer: 'NIMT',
      ),
    ],
    bio:
        'I am a welder in Swakopmund with over a decade of fabrication and repair work. I build gates, burglar bars, trailers, and steel frames, and I repair cracked metal on site where it is safe to do so. I work to a strong finish that stands up to coastal air, and I discuss measurements and design with you before any welding starts.',
  ),
  DemoWorker(
    name: 'Anna Shivute',
    town: 'Windhoek',
    country: 'Namibia',
    trade: TradeCategory.poolTechnician,
    experience: '2–5 years',
    photoUrl: 'https://randomuser.me/api/portraits/women/12.jpg',
    email: 'anna.shivute@kazi.na',
    phone: '081 123 4567',
    whatsapp: '081 123 4567',
    certifications: [
      DemoCertification(
        title: 'Pool Technician',
        issuer: 'Namibia Training Authority',
      ),
    ],
    bio:
        'I service pool pumps, filters, and chlorinators in Windhoek, not only the weekly clean. If your pool is green, the pump is noisy, or the salt system has stopped, I diagnose the cause and explain the repair in plain language. I stock common parts and I can set up a maintenance plan so the pool stays ready for family use.',
  ),
];
