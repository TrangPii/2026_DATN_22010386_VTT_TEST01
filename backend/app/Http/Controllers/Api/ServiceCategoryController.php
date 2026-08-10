<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\ServiceCategoryResource;
use App\Http\Resources\ServiceResource;
use App\Models\ServiceCategory;
use Illuminate\Http\JsonResponse;

class ServiceCategoryController extends Controller
{
    public function index(): JsonResponse
    {
        $categories = ServiceCategory::query()
            ->where('status', 'ACTIVE')
            ->withCount([
                'services' => fn ($query) =>
                    $query->where('status', 'ACTIVE'),
            ])
            ->orderBy('display_order')
            ->orderBy('name')
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'Lấy danh sách danh mục thành công.',
            'data' => [
                'categories' =>
                    ServiceCategoryResource::collection($categories),
            ],
        ]);
    }

    public function show(ServiceCategory $category): JsonResponse
    {
        if ($category->status !== 'ACTIVE') {
            abort(404);
        }

        $category->loadCount([
            'services' => fn ($query) =>
                $query->where('status', 'ACTIVE'),
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Lấy thông tin danh mục thành công.',
            'data' => [
                'category' =>
                    new ServiceCategoryResource($category),
            ],
        ]);
    }

    public function services(
    ServiceCategory $category
): JsonResponse {
    if ($category->status !== 'ACTIVE') {
        abort(404);
    }

    $services = $category
        ->services()
        ->where(
            'status',
            'ACTIVE'
        )
        ->whereHas(
            'provider',
            function ($query): void {
                $query
                    ->where(
                        'status',
                        'ACTIVE'
                    )
                    ->whereHas(
                        'providerProfile',
                        function ($profileQuery): void {
                            $profileQuery->where(
                                'verification_status',
                                'APPROVED'
                            );
                        }
                    );
            }
        )
        ->with([
            'category',
            'provider.providerProfile',
        ])
        ->latest()
        ->paginate(10);

    return response()->json([
        'success' => true,

        'message' =>
            'Lấy danh sách dịch vụ theo danh mục thành công.',

        'data' => [
            'services' =>
                ServiceResource::collection(
                    $services->items()
                ),

            'pagination' => [
                'current_page' =>
                    $services->currentPage(),

                'last_page' =>
                    $services->lastPage(),

                'per_page' =>
                    $services->perPage(),

                'total' =>
                    $services->total(),
            ],
        ],
    ]);
}
}