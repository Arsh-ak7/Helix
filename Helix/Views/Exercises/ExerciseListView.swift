import SwiftUI
import SwiftData

struct ExerciseListView: View {
    @Query(sort: \Exercise.name) var exercises: [Exercise]
    @State private var searchText = ""
    
    var filteredExercises: [Exercise] {
        if searchText.isEmpty { return exercises }
        return exercises.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    @State private var selectedExercise: Exercise?

    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredExercises) { exercise in
                    Button {
                        selectedExercise = exercise
                    } label: {
                        HStack {
                            Text(exercise.name)
                                .font(.system(.body, design: .serif))
                                .foregroundStyle(Color.primary)
                            Spacer()
                            if exercise.imageUrlString != nil {
                                Image(systemName: "photo")
                                    .foregroundStyle(.secondary)
                                    .font(.caption)
                            }
                        }
                    }
                    .listRowBackground(Color("AppSurface"))
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color("AppBackground"))
            .searchable(text: $searchText, prompt: "Search Library")
            .navigationTitle("Exercise Library")
            .sheet(item: $selectedExercise) { exercise in
                ExerciseDetailView(exercise: exercise)
                    .presentationDetents([.medium, .large])
            }
            .toolbar {
                 ToolbarItem(placement: .principal) {
                     Text("Exercise Library")
                         .font(.system(.headline, design: .serif))
                 }
            }
        }
    }
}
