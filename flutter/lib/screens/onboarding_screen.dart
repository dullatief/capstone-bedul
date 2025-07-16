import 'package:flutter/material.dart';
import 'package:klinik_bedul/screens/sign_in_screen.dart';
import '../theme/app_colors.dart';

class OnBoardingPage extends StatefulWidget {
  const OnBoardingPage({super.key});

  @override
  State<OnBoardingPage> createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage>
    with TickerProviderStateMixin {
  PageController pageController = PageController();
  int currentIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  List<Map<String, String>> onBoardingData = [
    {
      "title": "Pantau Kebutuhan Cairan",
      "subTitle":
          "Aplikasi ini membantu Anda mengetahui berapa banyak air yang harus diminum setiap hari.",
      "image":
          "https://cms.dailysocial.id/wp-content/uploads/2016/02/Waterminder1.png"
    },
    {
      "title": "Prediksi Berdasarkan Aktivitas",
      "subTitle":
          "Hanya dengan memilih tingkat aktivitas Anda, dapatkan rekomendasi air minum secara otomatis.",
      "image":
          "https://translate.google.com/website?sl=en&tl=id&hl=id&client=imgs&u=https://cdn.kodytechnolab.com/wp-content/uploads/2021/09/DRINK-WATER-%25E2%2580%2593-1.jpg"
    },
    {
      "title": "Riwayat & Tren Harian",
      "subTitle":
          "Pantau tren kebutuhan air Anda dari waktu ke waktu untuk hidup lebih sehat.",
      "image":
          "https://translate.google.com/website?sl=en&tl=id&hl=id&client=imgs&u=https://cdn.kodytechnolab.com/wp-content/uploads/2021/09/inner-1-1-1.jpg"
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: pageController,
                  itemCount: onBoardingData.length,
                  onPageChanged: (index) {
                    setState(() {
                      currentIndex = index;
                    });
                    _animationController.reset();
                    _animationController.forward();
                  },
                  itemBuilder: (context, index) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: OnBoardingLayout(
                        title: onBoardingData[index]["title"]!,
                        subTitle: onBoardingData[index]["subTitle"]!,
                        image: onBoardingData[index]["image"]!,
                      ),
                    );
                  },
                ),
              ),

              // Bottom section with indicators and button
              Container(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Page indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        onBoardingData.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: currentIndex == index ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: currentIndex == index
                                ? AppColors.primary
                                : AppColors.textHint,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Action buttons
                    Row(
                      children: [
                        if (currentIndex > 0)
                          TextButton(
                            onPressed: () {
                              pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: const Text('Kembali'),
                          )
                        else
                          const SizedBox(width: 80),
                        const Spacer(),
                        if (currentIndex < onBoardingData.length - 1)
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SignInScreen(),
                                ),
                              );
                            },
                            child: const Text('Lewati'),
                          ),
                        const SizedBox(width: 16),
                        Container(
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: IconButton(
                            onPressed: () {
                              if (currentIndex == onBoardingData.length - 1) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SignInScreen(),
                                  ),
                                );
                              } else {
                                pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            },
                            icon: Icon(
                              currentIndex == onBoardingData.length - 1
                                  ? Icons.check
                                  : Icons.arrow_forward,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OnBoardingLayout extends StatelessWidget {
  const OnBoardingLayout({
    super.key,
    required this.title,
    required this.subTitle,
    required this.image,
  });

  final String title;
  final String subTitle;
  final String image;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image with hero animation
          Hero(
            tag: image,
            child: Container(
              height: 280,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.cardShadow,
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  image,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.water_drop,
                        size: 100,
                        color: AppColors.primary,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          const SizedBox(height: 40),

          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),

          const SizedBox(height: 16),

          // Subtitle
          Text(
            subTitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }
}
