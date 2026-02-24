/// Example usage file for Responsive Design System
/// This file demonstrates various ways to use the responsive utilities

import 'package:flutter/material.dart';
import 'package:wood_service/Responsive/responsive.dart';

// ========== EXAMPLE 1: Basic Usage ==========
class BasicExample extends StatelessWidget {
  const BasicExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ScreenUtils.w(300),
      height: ScreenUtils.h(200),
      padding: ScreenUtils.paddingAll(16),
      margin: ScreenUtils.marginAll(8),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: ScreenUtils.borderRadius(12),
      ),
      child: Text(
        'Basic Example',
        style: TextStyle(
          fontSize: ScreenUtils.sp(16),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ========== EXAMPLE 2: Using Extensions ==========
class ExtensionExample extends StatelessWidget {
  const ExtensionExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.w(300), // Using context extension
      height: 200.h, // Using number extension
      padding: 16.space.paddingAll,
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: 12.r.borderRadius,
      ),
      child: Text(
        'Extension Example',
        style: TextStyle(fontSize: context.sp(16)),
      ),
    );
  }
}

// ========== EXAMPLE 3: Responsive Widgets ==========
class ResponsiveWidgetExample extends StatelessWidget {
  const ResponsiveWidgetExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveContainer(
      padding: EdgeInsets.all(16),
      child: ResponsiveColumn(
        spacing: 16,
        children: [
          ResponsiveText('Title', fontSize: 24, fontWeight: FontWeight.bold),
          ResponsiveText('Subtitle', fontSize: 16, color: Colors.grey),
        ],
      ),
    );
  }
}

// ========== EXAMPLE 4: Conditional Layout ==========
class ConditionalLayoutExample extends StatelessWidget {
  const ConditionalLayoutExample({super.key});

  @override
  Widget build(BuildContext context) {
    if (context.isTablet) {
      return TabletLayout();
    } else {
      return PhoneLayout();
    }
  }
}

class TabletLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ResponsiveRow(
      spacing: 24,
      children: [
        Expanded(child: LeftPanel()),
        Expanded(child: RightPanel()),
      ],
    );
  }
}

class PhoneLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ResponsiveColumn(spacing: 16, children: [TopPanel(), BottomPanel()]);
  }
}

class LeftPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.h(200),
      color: Colors.blue,
      child: Center(child: Text('Left Panel')),
    );
  }
}

class RightPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.h(200),
      color: Colors.green,
      child: Center(child: Text('Right Panel')),
    );
  }
}

class TopPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.h(150),
      color: Colors.blue,
      child: Center(child: Text('Top Panel')),
    );
  }
}

class BottomPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.h(150),
      color: Colors.green,
      child: Center(child: Text('Bottom Panel')),
    );
  }
}

// ========== EXAMPLE 5: Responsive Grid ==========
class GridExample extends StatelessWidget {
  final List<String> items = List.generate(10, (i) => 'Item ${i + 1}');

  @override
  Widget build(BuildContext context) {
    return ResponsiveGridView(
      children: items.map((item) => _buildGridItem(item)).toList(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 0.75,
    );
  }

  Widget _buildGridItem(String title) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: ScreenUtils.borderRadius(8),
      ),
      child: Center(
        child: Text(
          title,
          style: TextStyle(fontSize: ScreenUtils.sp(16), color: Colors.white),
        ),
      ),
    );
  }
}

// ========== EXAMPLE 6: Safe Area Handling ==========
class SafeAreaExample extends StatelessWidget {
  const SafeAreaExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: ScreenUtils.safeAreaPadding(context),
        child: Column(
          children: [
            Text('Top Safe Area: ${ScreenUtils.safeAreaTop(context)}'),
            Text('Bottom Safe Area: ${ScreenUtils.safeAreaBottom(context)}'),
            Expanded(child: Center(child: Text('Content'))),
          ],
        ),
      ),
    );
  }
}

// ========== EXAMPLE 7: Keyboard Handling ==========
class KeyboardExample extends StatelessWidget {
  const KeyboardExample({super.key});

  @override
  Widget build(BuildContext context) {
    final keyboardVisible = ScreenUtils.isKeyboardVisible(context);
    final keyboardHeight = ScreenUtils.keyboardHeight(context);

    return Scaffold(
      body: Column(
        children: [
          Text('Keyboard Visible: $keyboardVisible'),
          Text('Keyboard Height: $keyboardHeight'),
          Expanded(
            child: Center(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Type here...',
                  border: OutlineInputBorder(
                    borderRadius: ScreenUtils.borderRadius(8),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ========== EXAMPLE 8: Screen Information ==========
class ScreenInfoExample extends StatelessWidget {
  const ScreenInfoExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveColumn(
      spacing: 16,
      children: [
        Text('Screen Width: ${ScreenUtils.screenWidth}'),
        Text('Screen Height: ${ScreenUtils.screenHeight}'),
        Text('Is Tablet: ${ScreenUtils.isTablet}'),
        Text('Is Phone: ${ScreenUtils.isPhone}'),
        Text('Is Small Phone: ${ScreenUtils.isSmallPhone}'),
        Text('Is Large Phone: ${ScreenUtils.isLargePhone}'),
        Text('Pixel Ratio: ${ScreenUtils.pixelRatio}'),
        Text('Status Bar Height: ${ScreenUtils.statusBarHeight}'),
        Text('Is Landscape: ${context.isLandscape}'),
        Text('Is Portrait: ${context.isPortrait}'),
      ],
    );
  }
}

// ========== EXAMPLE 9: Complex Layout ==========
class ComplexLayoutExample extends StatelessWidget {
  const ComplexLayoutExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ResponsiveText(
          'Complex Layout',
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: ResponsiveContainer(
        child: ResponsiveColumn(
          spacing: 24,
          children: [_buildHeader(), _buildContent(), _buildFooter()],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: ScreenUtils.paddingAll(16),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: ScreenUtils.borderRadiusTop(12),
      ),
      child: ResponsiveText(
        'Header',
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildContent() {
    return Expanded(
      child: ResponsiveRow(
        spacing: 16,
        children: [
          Expanded(
            child: Container(
              padding: ScreenUtils.paddingAll(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: ScreenUtils.borderRadius(8),
              ),
              child: ResponsiveText('Content 1', fontSize: 16),
            ),
          ),
          Expanded(
            child: Container(
              padding: ScreenUtils.paddingAll(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: ScreenUtils.borderRadius(8),
              ),
              child: ResponsiveText('Content 2', fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: ScreenUtils.paddingAll(16),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: ScreenUtils.borderRadiusBottom(12),
      ),
      child: ResponsiveText(
        'Footer',
        fontSize: 16,
        color: Colors.white,
        textAlign: TextAlign.center,
      ),
    );
  }
}
