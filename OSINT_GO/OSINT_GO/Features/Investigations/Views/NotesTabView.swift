//
//  NotesTabView.swift
//  OSINT_GO
//
//  Created by M1N0-H1DDEN on 12.12.2025.
//


import SwiftUI
import SwiftData

struct NotesTabView: View {
    @ObservedObject var investigation: Investigation
    @Environment(\.modelContext) private var modelContext
    @State private var newNoteContent = ""
    @State private var editingNote: Note?
    @State private var showingAddNote = false
    
    var body: some View {
        VStack(spacing: 12) {
            // Roots section
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label("Investigation Roots", systemImage: "tree")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Spacer()
                    Button {
                        editingNote = nil
                        showingAddNote = true
                    } label: {
                        Image(systemName: "square.and.pencil")
                            .foregroundStyle(.white)
                    }
                }
                
                Text(investigation.roots.isEmpty ? "No roots documented yet" : investigation.roots)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            // Notes section
            HStack {
                Text("Notes")
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
                Button {
                    addNewNote()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.white)
                }
            }
            
            ScrollView {
                if investigation.notes.isEmpty {
                    EmptyStateView(
                        title: "No Notes",
                        message: "Add notes to track your investigation progress",
                        icon: "note.text"
                    )
                    .padding()
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(investigation.notes.sorted(by: { $0.updatedAt > $1.updatedAt })) { note in
                            NoteCardView(note: note) {
                                editingNote = note
                                newNoteContent = note.content
                                showingAddNote = true
                            } onDelete: {
                                deleteNote(note)
                            }
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
        .sheet(isPresented: $showingAddNote) {
            NoteEditorView(
                content: $newNoteContent,
                isRoots: editingNote == nil,
                onSave: {
                    if editingNote != nil {
                        updateNote()
                    } else {
                        saveRoots()
                    }
                    showingAddNote = false
                }
            )
        }
    }
    
    private func addNewNote() {
        let note = Note(content: "")
        investigation.notes.append(note)
        note.investigation = investigation
        modelContext.insert(note)
        editingNote = note
        newNoteContent = ""
        showingAddNote = true
    }
    
    private func updateNote() {
        if let note = editingNote {
            note.content = newNoteContent
            note.updatedAt = Date()
            try? modelContext.save()
        }
        editingNote = nil
        newNoteContent = ""
    }
    
    private func saveRoots() {
        investigation.roots = newNoteContent
        investigation.updatedAt = Date()
        try? modelContext.save()
        newNoteContent = ""
    }
    
    private func deleteNote(_ note: Note) {
        if let index = investigation.notes.firstIndex(where: { $0.id == note.id }) {
            investigation.notes.remove(at: index)
            modelContext.delete(note)
            try? modelContext.save()
        }
    }
}

struct NoteCardView: View {
    let note: Note
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "note.text")
                    .foregroundStyle(.blue)
                
                Text(note.updatedAt, style: .relative)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .font(.caption)
                        .foregroundStyle(.blue)
                }
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }
            
            Text(note.content.isEmpty ? "Empty note" : note.content)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .lineLimit(3)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct NoteEditorView: View {
    @Binding var content: String
    let isRoots: Bool
    let onSave: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                TextEditor(text: $content)
                    .padding()
                    .scrollContentBackground(.hidden)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding()
            }
            .navigationTitle(isRoots ? "Edit Roots" : "Edit Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave()
                        dismiss()
                    }
                }
            }
        }
    }
}
