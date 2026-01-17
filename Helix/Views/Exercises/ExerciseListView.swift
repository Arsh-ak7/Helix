import SwiftUI
import SwiftData

struct ExerciseListView: View {
    @Query(sort: \Exercise.name) var exercises: [Exercise]
    @State private var searchText = ""
    @State private var selectedMuscle: String? = nil
    @State private var selectedEquipment: String? = nil
    
    var filteredExercises: [Exercise] {
        exercises.filter { exercise in
            let matchesSearch = searchText.isEmpty || exercise.name.localizedCaseInsensitiveContains(searchText)
            let matchesMuscle = selectedMuscle == nil || exercise.muscleGroup?.localizedCaseInsensitiveContains(selectedMuscle!) == true
            let matchesEquipment = selectedEquipment == nil || exercise.equipment?.localizedCaseInsensitiveContains(selectedEquipment!) == true
            return matchesSearch && matchesMuscle && matchesEquipment
        }
    }
    
    @State private var selectedExercise: Exercise?
    
    let muscles = ["Abdominals", "Biceps", "Shoulders", "Chest", "Back", "Triceps", "Quads", "Hamstrings", "Glutes", "Calves"]
    let equipment = ["Body Only", "Barbell", "Dumbbell", "Machine", "Cable", "Kettlebell"]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filter Bar
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        FilterChip(title: "All", isSelected: selectedMuscle == nil && selectedEquipment == nil) {
                            selectedMuscle = nil
                            selectedEquipment = nil
                        }
                        
                        Divider().frame(height: 20)
                        
                        Menu {
                            Button("All Muscles") { selectedMuscle = nil }
                            ForEach(muscles, id: \.self) { muscle in
                                Button(muscle) { selectedMuscle = muscle }
                            }
                        } label: {
                            FilterChip(title: selectedMuscle ?? "Muscle", isSelected: selectedMuscle != nil)
                        }
                        
                        Menu {
                            Button("All Equipment") { selectedEquipment = nil }
                            ForEach(equipment, id: \.self) { item in
                                Button(item) { selectedEquipment = item }
                            }
                        } label: {
                            FilterChip(title: selectedEquipment ?? "Equipment", isSelected: selectedEquipment != nil)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                }
                .background(Color("AppSurface"))
                
                List {
                    ForEach(filteredExercises) { exercise in
                        Button {
                            selectedExercise = exercise
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(exercise.name)
                                        .font(.system(.body, design: .serif))
                                        .fontWeight(.medium)
                                        .foregroundStyle(Color.primary)
                                    
                                    HStack(spacing: 8) {
                                        if let muscle = exercise.muscleGroup {
                                            Text(muscle)
                                                .font(.caption2)
                                                .foregroundStyle(.secondary)
                                        }
                                        
                                        if let level = exercise.level {
                                            Text("•")
                                                .font(.caption2)
                                                .foregroundStyle(.tertiary)
                                            Text(level)
                                                .font(.caption2)
                                                .foregroundStyle(level == "Beginner" ? .green : .orange)
                                        }
                                    }
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                            .padding(.vertical, 8)
                        }
                        .listRowBackground(Color("AppSurface"))
                    }
                }
                .listStyle(.plain)
            }
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

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    var action: (() -> Void)? = nil
    
    var body: some View {
        if let action = action {
            Button(action: action) { chipContent }
        } else {
            chipContent
        }
    }
    
    private var chipContent: some View {
        HStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
            if !isSelected && action == nil {
                Image(systemName: "chevron.down")
                    .font(.system(size: 8))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(isSelected ? Color("AppAccent") : Color.primary.opacity(0.05))
        .foregroundStyle(isSelected ? .white : .primary)
        .cornerRadius(20)
    }
}
