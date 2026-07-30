<?php

namespace App\Http\Controllers;

use App\Models\DocumentType;
use Illuminate\Http\Request;

class DocumentTypeController extends Controller
{
    public function index()
    {
        $types = DocumentType::latest()->get();
        return response()->json(['data' => $types]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required|string|unique:document_types,name|max:255',
            'description' => 'nullable|string'
        ]);

        $type = DocumentType::create([
            'name' => $request->name,
            'description' => $request->description,
            'is_active' => true
        ]);

        return response()->json(['message' => 'Document Type created successfully', 'data' => $type], 201);
    }

    public function show($id)
    {
        return response()->json(['data' => DocumentType::findOrFail($id)]);
    }

    public function update(Request $request, $id)
    {
        $type = DocumentType::findOrFail($id);

        $request->validate([
            'name' => 'required|string|max:255|unique:document_types,name,' . $id,
            'description' => 'nullable|string'
        ]);

        $type->update([
            'name' => $request->name,
            'description' => $request->description
        ]);

        return response()->json(['message' => 'Document Type updated successfully', 'data' => $type]);
    }

    public function toggle($id)
    {
        $type = DocumentType::findOrFail($id);
        $type->is_active = !$type->is_active;
        $type->save();
        return response()->json(['message' => 'Document Type status toggled', 'is_active' => $type->is_active]);
    }

    public function destroy($id)
    {
        DocumentType::findOrFail($id)->delete();
        return response()->json(['message' => 'Document Type deleted permanently']);
    }
}
