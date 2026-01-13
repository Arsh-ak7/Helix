import SwiftUI

struct ExerciseDetailView: View {
    let exercise: Exercise
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Image
                if let urlString = exercise.imageUrlString, let url = URL(string: urlString) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            Rectangle()
                                .fill(Color("AppSurface"))
                                .frame(height: 250)
                                .overlay(ProgressView())
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: .infinity)
                                .background(Color.white)
                                .cornerRadius(12)
                        case .failure:
                            Rectangle()
                                .fill(Color("AppSurface"))
                                .frame(height: 250)
                                .overlay(Image(systemName: "photo.fill").foregroundStyle(.secondary))
                        @unknown default:
                            EmptyView()
                        }
                    }
                }
                
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(exercise.name)
                        .font(.system(.title, design: .serif))
                        .fontWeight(.bold)
                    
                    if let muscle = exercise.muscleGroup {
                        Text(muscle)
                            .font(.subheadline)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color("AppSurface"))
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.primary.opacity(0.1)))
                    }
                }
                .padding(.horizontal)
                
                // Charts
                ExerciseHistoryChartView(exercise: exercise)
                    .padding(.horizontal)
                
                // Description
                if let description = exercise.descriptionText, !description.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Instructions")
                            .font(.headline)
                            .fontDesign(.serif)
                        
                        Text(description)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .lineSpacing(6)
                    }
                    .padding(.horizontal)
                } else {
                    Text("No instructions available.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .background(Color("AppBackground"))
        .ignoresSafeArea(edges: .bottom)
    }
}
