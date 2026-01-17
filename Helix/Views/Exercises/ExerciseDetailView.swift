import SwiftUI

struct ExerciseDetailView: View {
    let exercise: Exercise
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Gallery
                if let images = exercise.images, !images.isEmpty {
                    TabView {
                        ForEach(images, id: \.self) { urlString in
                            if let url = URL(string: urlString) {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(maxWidth: .infinity)
                                        .background(Color.white)
                                } placeholder: {
                                    ProgressView()
                                }
                            }
                        }
                    }
                    .frame(height: 320)
                    .tabViewStyle(PageTabViewStyle())
                    .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                    .ignoresSafeArea(edges: .top)
                }
                
                VStack(alignment: .leading, spacing: 32) {
                    // Header
                    VStack(alignment: .leading, spacing: 12) {
                        Text(exercise.name)
                            .font(.system(.title, design: .serif))
                            .fontWeight(.bold)
                        
                        HStack(spacing: 8) {
                            if let muscle = exercise.muscleGroup {
                                Badge(text: muscle, color: Color("AppAccent"))
                            }
                            if let level = exercise.level {
                                Badge(text: level, color: level == "Beginner" ? .green : .orange)
                            }
                        }
                    }
                    
                    // Info Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        InfoCard(title: "Force", value: exercise.force ?? "N/A", icon: "bolt.fill")
                        InfoCard(title: "Mechanic", value: exercise.mechanic ?? "N/A", icon: "gearshape.2.fill")
                        InfoCard(title: "Equipment", value: exercise.equipment ?? "Body Only", icon: "gym.bag.fill")
                        InfoCard(title: "Category", value: exercise.category ?? "Strength", icon: "figure.strengthtraining.traditional")
                    }
                    
                    // Muscles Section
                    if let secondary = exercise.secondaryMuscles {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Secondary Muscles")
                                .font(.headline)
                                .fontDesign(.serif)
                            Text(secondary)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    // Charts
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Progress")
                            .font(.headline)
                            .fontDesign(.serif)
                        ExerciseHistoryChartView(exercise: exercise)
                    }
                    
                    // Description
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Instructions")
                            .font(.headline)
                            .fontDesign(.serif)
                        
                        if let description = exercise.descriptionText, !description.isEmpty {
                            Text(description)
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .lineSpacing(6)
                        } else {
                            Text("No instructions available.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(24)
            }
        }
        .background(Color("AppBackground"))
        .ignoresSafeArea(edges: .bottom)
    }
}

struct Badge: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(.caption)
            .fontWeight(.bold)
            .foregroundStyle(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(color.opacity(0.1))
            .cornerRadius(6)
    }
}

struct InfoCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
                .font(.footnote)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                Text(value)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            Spacer()
        }
        .padding(12)
        .background(Color("AppSurface"))
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.primary.opacity(0.05)))
    }
}
