import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AuraSecureLogo extends StatefulWidget {
  final double size;
  final bool showShadow;

  const AuraSecureLogo({
    Key? key,
    this.size = 40.0,
    this.showShadow = true,
  }) : super(key: key);

  @override
  _AuraSecureLogoState createState() => _AuraSecureLogoState();
}

class _AuraSecureLogoState extends State<AuraSecureLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            padding: EdgeInsets.all(widget.size * 0.25),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.pink[50]!.withOpacity(0.8),
                  Colors.purple[100]!.withOpacity(0.6),
                  Colors.pink[200]!.withOpacity(0.3),
                ],
                stops: [0.0, 0.7, 1.0],
                center: Alignment.center,
              ),
              boxShadow: widget.showShadow
                  ? [
                      BoxShadow(
                        color: Colors.pink[200]!.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(2, 2),
                      ),
                      BoxShadow(
                        color: Colors.purple[200]!.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(-2, -2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: SvgPicture.asset(
                          'images/shield_a.svg',
                          height: widget.size * 0.6,
                          width: widget.size * 0.6,
                          color: Colors.pink[600],
                        ),
                      ),
                      TextSpan(
                        text: 'ura',
                        style: TextStyle(
                          color: Colors.pink[600],
                          fontSize: widget.size * 0.45,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          shadows: [
                            Shadow(
                              color: Colors.pink[200]!.withOpacity(0.5),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: widget.size * 0.15),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Secure',
                        style: TextStyle(
                          color: Colors.purple[600],
                          fontSize: widget.size * 0.45,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          shadows: [
                            Shadow(
                              color: Colors.purple[200]!.withOpacity(0.5),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
