<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\ServiceResource;
use App\Models\Service;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ServiceController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'category_id' => [
                'nullable',
                'integer',
                'exists:service_categories,id',
            ],

            'provider_id' => [
                'nullable',
                'integer',
                'exists:users,id',
            ],

            'search' => [
                'nullable',
                'string',
                'max:100',
            ],

            'min_price' => [
                'nullable',
                'numeric',
                'min:0',
            ],

            'max_price' => [
                'nullable',
                'numeric',
                'min:0',
                'gte:min_price',
            ],

            'per_page' => [
                'nullable',
                'integer',
                'min:1',
                'max:50',
            ],
        ]);

        $query = Service::query()
            ->where('status', 'ACTIVE')
            ->whereHas(
                'category',
                fn ($query) =>
                    $query->where('status', 'ACTIVE')
            )
            ->whereHas(
                'provider',
                fn ($query) =>
                    $query
                        ->where('role', 'PROVIDER')
                        ->where('status', 'ACTIVE')
            )
            ->with([
                'category',
                'provider.providerProfile',
            ]);

        if (! empty($validated['category_id'])) {
            $query->where(
                'category_id',
                $validated['category_id']
            );
        }

        if (! empty($validated['provider_id'])) {
            $query->where(
                'provider_id',
                $validated['provider_id']
            );
        }

        if (! empty($validated['search'])) {
            $search = $validated['search'];

            $query->where(function ($query) use ($search): void {
                $query
                    ->where('name', 'like', "%{$search}%")
                    ->orWhere(
                        'description',
                        'like',
                        "%{$search}%"
                    );
            });
        }

        if (isset($validated['min_price'])) {
            $query->where(
                'price',
                '>=',
                $validated['min_price']
            );
        }

        if (isset($validated['max_price'])) {
            $query->where(
                'price',
                '<=',
                $validated['max_price']
            );
        }

        $services = $query
            ->latest()
            ->paginate($validated['per_page'] ?? 10);

        return response()->json([
            'success' => true,
            'message' => 'Lấy danh sách dịch vụ thành công.',
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

    public function show(Service $service): JsonResponse
    {
        if ($service->status !== 'ACTIVE') {
            abort(404);
        }

        $service->load([
            'category',
            'provider.providerProfile',
        ]);

        if (
            $service->category->status !== 'ACTIVE' ||
            $service->provider->status !== 'ACTIVE'
        ) {
            abort(404);
        }

        return response()->json([
            'success' => true,
            'message' => 'Lấy thông tin dịch vụ thành công.',
            'data' => [
                'service' => new ServiceResource($service),
            ],
        ]);
    }
}