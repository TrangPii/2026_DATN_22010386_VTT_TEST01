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
    public function index(
        Request $request
    ): JsonResponse {
        $validated =
            $request->validate([
                'sort' => [
                    'nullable',
                    'in:newest,services_asc,services_desc',
                ],

                'status' => [
                    'nullable',
                    'in:ACTIVE,INACTIVE',
                ],

                'search' => [
                    'nullable',
                    'string',
                    'max:100',
                ],
            ]);

        $query =
            ServiceCategory::query()
                ->withCount(
                    'services'
                );

        if (
            ! empty(
                $validated['search']
            )
        ) {
            $search =
                trim(
                    $validated['search']
                );

            $query->where(
                function (
                    $query
                ) use ($search): void {
                    $query
                        ->where(
                            'name',
                            'like',
                            "%{$search}%"
                        )
                        ->orWhere(
                            'description',
                            'like',
                            "%{$search}%"
                        );
                }
            );
        }

        if (
            ! empty(
                $validated['status']
            )
        ) {
            $query->where(
                'status',
                $validated['status']
            );
        }

        $sort =
            $validated['sort']
                ?? 'newest';

        switch ($sort) {
            case 'services_asc':
                $query
                    ->orderBy(
                        'services_count',
                        'asc'
                    )
                    ->orderByDesc(
                        'created_at'
                    )
                    ->orderByDesc(
                        'id'
                    );

                break;

            case 'services_desc':
                $query
                    ->orderByDesc(
                        'services_count'
                    )
                    ->orderByDesc(
                        'created_at'
                    )
                    ->orderByDesc(
                        'id'
                    );

                break;

            case 'newest':
            default:
                $query
                    ->orderByDesc(
                        'created_at'
                    )
                    ->orderByDesc(
                        'id'
                    );

                break;
        }

        $categories =
            $query->get();

        return response()->json([
            'success' => true,

            'message' =>
                'Lấy danh sách danh mục thành công.',

            'data' => [
                'categories' =>
                    ServiceCategoryResource::
                        collection(
                            $categories
                        ),
            ],
        ]);
    }

    public function store(
        StoreCategoryRequest $request
    ): JsonResponse {
        $validated =
            $request->validated();

        $category =
            ServiceCategory::create([
                'name' =>
                    trim(
                        $validated['name']
                    ),

                'slug' =>
                    $this
                        ->generateUniqueSlug(
                            $validated['name']
                        ),

                'description' =>
                    $validated[
                        'description'
                    ] ?? null,

                'image' =>
                    $validated[
                        'image'
                    ] ?? null,

                'status' =>
                    'ACTIVE',
            ]);

        return response()->json([
            'success' => true,

            'message' =>
                'Tạo danh mục thành công.',

            'data' => [
                'category' =>
                    new ServiceCategoryResource(
                        $category
                    ),
            ],
        ], 201);
    }

    public function update(
        UpdateCategoryRequest $request,
        ServiceCategory $category
    ): JsonResponse {
        $validated =
            $request->validated();

        if (
            isset(
                $validated['name']
            )
        ) {
            $validated['name'] =
                trim(
                    $validated['name']
                );

            if (
                $validated['name'] !==
                $category->name
            ) {
                $validated['slug'] =
                    $this
                        ->generateUniqueSlug(
                            $validated['name'],
                            $category->id
                        );
            }
        }

        $category->update(
            $validated
        );

        return response()->json([
            'success' => true,

            'message' =>
                'Cập nhật danh mục thành công.',

            'data' => [
                'category' =>
                    new ServiceCategoryResource(
                        $category
                    ),
            ],
        ]);
    }

    public function updateStatus(
        Request $request,
        ServiceCategory $category
    ): JsonResponse {
        $validated =
            $request->validate([
                'status' => [
                    'required',
                    'in:ACTIVE,INACTIVE',
                ],
            ]);

        $category->update([
            'status' =>
                $validated['status'],
        ]);

        return response()->json([
            'success' => true,

            'message' =>
                'Cập nhật trạng thái danh mục thành công.',

            'data' => [
                'category' =>
                    new ServiceCategoryResource(
                        $category
                    ),
            ],
        ]);
    }

    private function generateUniqueSlug(
        string $name,
        ?int $ignoreId = null
    ): string {
        $base =
            Str::slug(
                trim($name)
            );

        if (
            $base === ''
        ) {
            $base =
                'category';
        }

        $slug =
            $base;

        $counter =
            2;

        while (
            ServiceCategory::query()
                ->where(
                    'slug',
                    $slug
                )
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
            $slug =
                $base
                . '-'
                . $counter++;

        }

        return $slug;
    }
}