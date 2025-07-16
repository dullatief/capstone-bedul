# WaterApp - Menu Structure and Flowcharts

This directory contains UML diagrams for the menu structure and key process flowcharts for the WaterApp application.

## Menu Structure

The menu structure diagram (`menu_structure.md`) illustrates the hierarchy of screens and navigation paths within the application. It shows:

- The main sections accessible from the home screen
- The subsections within each main section
- The logical organization of features

This diagram helps to understand the overall application navigation and can be used for planning UI/UX improvements.

## User Flow Diagram

The user flow diagram (`user_flow.md`) shows the typical paths users take through the application, organized by functional areas:

- Authentication
- Home Screen
- Water Tracking
- Social Features
- Statistics & Analysis
- Settings & Profile

This diagram helps visualize how users interact with the application across different features.

## Process Flowcharts

The process flowcharts detail specific functional flows within the application:

1. **Water Consumption Tracking Process** (`water_tracking_flowchart.md`)

   - Shows the step-by-step flow when a user tracks water consumption
   - Includes branching for different tracking methods
   - Details the backend processes triggered by tracking

2. **Competition Lifecycle** (`competition_flowchart.md`)

   - Illustrates the complete lifecycle of a competition
   - Shows state transitions from creation to completion
   - Details participant interactions and system updates

3. **AI Water Prediction Process** (`ai_prediction_flowchart.md`)
   - Shows how the AI generates personalized water intake recommendations
   - Includes data collection, model processing, and result presentation
   - Details the weather-based adjustments to recommendations

## How to Use These Diagrams

These diagrams can be used for:

- Developer onboarding to understand application structure
- Planning new features or modifications
- Identifying potential UX improvements
- Documentation for stakeholders

To render the diagrams, use any PlantUML compatible tool or online service like [PlantUML Server](http://www.plantuml.com/plantuml/uml/).
