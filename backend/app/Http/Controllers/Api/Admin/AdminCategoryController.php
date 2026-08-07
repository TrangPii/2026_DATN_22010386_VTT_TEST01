<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\StoreCategoryRequest;
use App\Http\Requests\Admin\UpdateCategoryRequest;
use App\Http\Resources\ServiceCategoryResource;
use App\Models\ServiceCategory;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class AdminCategoryController extends Controller
{
    public function index(): JsonResponse
    {
        $categories = ServiceCategory::query()
            ->withCount('services')
            ->orderBy('display_order')
            ->get();

        return response()->json([
            'success' => true,
            'message' =>
                'Lấy danh sách danh mục thành công.',

            'data' => [
                'categories' =>
                    ServiceCategoryResource::collection(
                        $categories
                    ),
            ],
        ]);
    }

    public function store(
        StoreCategoryRequest $request
    ): JsonResponse {
        $validated = $request->validated();

        $category = ServiceCategory::create([
            'name' => $validated['name'],
            'slug' =>
                $this->generateUniqueSlug(
                    $validated['name']
                ),

            'description' =>
                $validated['description'] ?? null,

            'image' =>
                $validated['image'] ?? null,

            'display_order' =>
                $validated['display_order'] ?? 0,

            'status' => 'ACTIVE',
        ]);

        return response()->json([
            'success' => true,
            'message' =>
                'Tạo danh mục thành công.',

            'data' => [
                'category' =>
                    new ServiceCategoryResource($category),
            ],
        ], 201);
    }

    public function update(
        UpdateCategoryRequest $request,
        ServiceCategory $category
    ): JsonResponse {
        $validated = $request->validated();

        if (isset($validated['name'])) {
            $validated['slug'] =
                $this->generateUniqueSlug(
                    $validated['name'],
                    $category->id
                );
        }

        $category->update($validated);

        return response()->json([
            'success' => true,
            'message' =>
                'Cập nhật danh mục thành công.',

            'data' => [
                'category' =>
                    new ServiceCategoryResource($category),
            ],
        ]);
    }

    public function updateStatus(
        Request $request,
        ServiceCategory $category
    ): JsonResponse {
        $validated = $request->validate([
            'status' => [
                'required',
                'in:ACTIVE,INACTIVE',
            ],
        ]);

        $category->update([
            'status' => $validated['status'],
        ]);

        return response()->json([
            'success' => true,
            'message' =>
                'Cập nhật trạng thái danh mục thành công.',

            'data' => [
                'category' =>
                    new ServiceCategoryResource($category),
            ],
        ]);
    }

    private function generateUniqueSlug(
        string $name,
        ?int $ignoreId = null
    ): string {
        $base = Str::slug($name);

        if ($base === '') {
            $base = 'category';
        }

        $slug = $base;
        $counter = 2;

        while (
            ServiceCategory::query()
                ->where('slug', $slug)
                ->when(
                    $ignoreId !== null,
                    fn ($query) =>
                        $query->where(
                            'id',
                            '!=',
                            $ignoreId
                        )
                )
                ->exists()
        ) {
            $slug = $base . '-' . $counter++;
        }

        return $slug;
    }
}