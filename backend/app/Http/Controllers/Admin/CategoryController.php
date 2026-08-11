<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\StoreCategoryRequest;
use App\Http\Requests\Admin\UpdateCategoryRequest;
use App\Models\ServiceCategory;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Str;
use Illuminate\View\View;

class CategoryController extends Controller
{
    public function index(
        Request $request
    ): View {
        $validated =
            $request->validate([
                'search' => [
                    'nullable',
                    'string',
                    'max:100',
                ],

                'status' => [
                    'nullable',
                    'in:ACTIVE,INACTIVE',
                ],

                'sort' => [
                    'nullable',
                    'in:newest,services_asc,services_desc',
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
            $query
                ->paginate(10)
                ->withQueryString();

        return view(
            'admin.categories.category_list',
            compact('categories')
        );
    }

    public function create(): View
    {
        return view(
            'admin.categories.category_create'
        );
    }

    public function store(
        StoreCategoryRequest $request
    ): RedirectResponse {
        $validated =
            $request->validated();

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

        return redirect()
            ->route(
                'admin.categories.index'
            )
            ->with(
                'success',
                'Đã tạo danh mục dịch vụ.'
            );
    }

    public function edit(
        ServiceCategory $category
    ): View {
        return view(
            'admin.categories.category_edit',
            compact('category')
        );
    }

    public function update(
        UpdateCategoryRequest $request,
        ServiceCategory $category
    ): RedirectResponse {
        $validated =
            $request->validated();

        if (
            isset(
                $validated['name']
            )
            && trim(
                $validated['name']
            ) !==
                $category->name
        ) {
            $validated['name'] =
                trim(
                    $validated['name']
                );

            $validated['slug'] =
                $this
                    ->generateUniqueSlug(
                        $validated['name'],
                        $category->id
                    );
        }

        $category->update(
            $validated
        );

        return redirect()
            ->route(
                'admin.categories.index'
            )
            ->with(
                'success',
                'Đã cập nhật danh mục dịch vụ.'
            );
    }

    public function updateStatus(
        Request $request,
        ServiceCategory $category
    ): RedirectResponse {
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

        return back()->with(
            'success',
            $validated['status'] ===
                'ACTIVE'
                ? 'Đã kích hoạt danh mục.'
                : 'Đã tạm ngừng danh mục.'
        );
    }

    private function generateUniqueSlug(
        string $name,
        ?int $ignoreCategoryId = null
    ): string {
        $baseSlug =
            Str::slug(
                trim($name)
            );

        if (
            $baseSlug === ''
        ) {
            $baseSlug =
                'category';
        }

        $slug =
            $baseSlug;

        $counter =
            2;

        while (
            ServiceCategory::query()
                ->where(
                    'slug',
                    $slug
                )
                ->when(
                    $ignoreCategoryId !== null,
                    fn ($query) =>
                        $query->where(
                            'id',
                            '!=',
                            $ignoreCategoryId
                        )
                )
                ->exists()
        ) {
            $slug =
                $baseSlug
                . '-'
                . $counter;

            $counter++;
        }

        return $slug;
    }
}