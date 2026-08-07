<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Service\StoreServiceRequest;
use App\Http\Requests\Service\UpdateServiceRequest;
use App\Http\Requests\Service\UpdateServiceStatusRequest;
use App\Http\Resources\ServiceResource;
use App\Models\Service;
use App\Models\ServiceCategory;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class ProviderServiceController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $this->ensureProvider($request);

        $validated = $request->validate([
            'status' => [
                'nullable',
                'string',
                'in:ACTIVE,INACTIVE',
            ],

            'category_id' => [
                'nullable',
                'integer',
                'exists:service_categories,id',
            ],

            'search' => [
                'nullable',
                'string',
                'max:100',
            ],

            'per_page' => [
                'nullable',
                'integer',
                'min:1',
                'max:50',
            ],
        ]);

        $query = Service::query()
            ->where(
                'provider_id',
                $request->user()->id
            )
            ->with([
                'category',
                'provider.providerProfile',
            ])
            ->latest();

        if (! empty($validated['status'])) {
            $query->where(
                'status',
                $validated['status']
            );
        }

        if (! empty($validated['category_id'])) {
            $query->where(
                'category_id',
                $validated['category_id']
            );
        }

        if (! empty($validated['search'])) {
            $search = $validated['search'];

            $query->where(
                function ($query) use ($search): void {
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

        $services = $query->paginate(
            $validated['per_page'] ?? 10
        );

        return response()->json([
            'success' => true,
            'message' =>
                'Lấy danh sách dịch vụ của nhà cung cấp thành công.',

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

    public function show(
        Request $request,
        Service $service
    ): JsonResponse {
        $this->ensureOwnsService(
            $request,
            $service
        );

        $service->load([
            'category',
            'provider.providerProfile',
        ]);

        return response()->json([
            'success' => true,
            'message' =>
                'Lấy thông tin dịch vụ thành công.',

            'data' => [
                'service' =>
                    new ServiceResource($service),
            ],
        ]);
    }

    public function store(
        StoreServiceRequest $request
    ): JsonResponse {
        $validated = $request->validated();

        $provider = $request->user();

        if (
            $provider->providerProfile === null ||
            $provider
                ->providerProfile
                ->verification_status !== 'APPROVED'
        ) {
            return response()->json([
                'success' => false,
                'message' =>
                    'Nhà cung cấp chưa được xác minh.',
            ], 403);
        }

        $category = ServiceCategory::query()
            ->findOrFail($validated['category_id']);

        if ($category->status !== 'ACTIVE') {
            return response()->json([
                'success' => false,
                'message' =>
                    'Danh mục dịch vụ hiện không hoạt động.',
            ], 422);
        }

        $slug = $this->generateUniqueSlug(
            $provider->id,
            $validated['name']
        );

        $service = Service::create([
            'category_id' =>
                $validated['category_id'],

            'provider_id' =>
                $provider->id,

            'name' =>
                $validated['name'],

            'slug' =>
                $slug,

            'description' =>
                $validated['description'] ?? null,

            'price' =>
                $validated['price'],

            'price_unit' =>
                $validated['price_unit'],

            'estimated_duration_minutes' =>
                $validated[
                    'estimated_duration_minutes'
                ] ?? null,

            'image' =>
                $validated['image'] ?? null,

            'status' =>
                'ACTIVE',
        ]);

        $service->load([
            'category',
            'provider.providerProfile',
        ]);

        return response()->json([
            'success' => true,
            'message' =>
                'Tạo dịch vụ thành công.',

            'data' => [
                'service' =>
                    new ServiceResource($service),
            ],
        ], 201);
    }

    public function update(
        UpdateServiceRequest $request,
        Service $service
    ): JsonResponse {
        $this->ensureOwnsService(
            $request,
            $service
        );

        $validated = $request->validated();

        if (isset($validated['category_id'])) {
            $category = ServiceCategory::query()
                ->findOrFail(
                    $validated['category_id']
                );

            if ($category->status !== 'ACTIVE') {
                return response()->json([
                    'success' => false,
                    'message' =>
                        'Danh mục dịch vụ hiện không hoạt động.',
                ], 422);
            }
        }

        if (isset($validated['name'])) {
            $validated['slug'] =
                $this->generateUniqueSlug(
                    $request->user()->id,
                    $validated['name'],
                    $service->id
                );
        }

        $service->update($validated);

        $service->load([
            'category',
            'provider.providerProfile',
        ]);

        return response()->json([
            'success' => true,
            'message' =>
                'Cập nhật dịch vụ thành công.',

            'data' => [
                'service' =>
                    new ServiceResource($service),
            ],
        ]);
    }

    public function updateStatus(
        UpdateServiceStatusRequest $request,
        Service $service
    ): JsonResponse {
        $this->ensureOwnsService(
            $request,
            $service
        );

        $service->update([
            'status' =>
                $request->validated('status'),
        ]);

        $service->load([
            'category',
            'provider.providerProfile',
        ]);

        return response()->json([
            'success' => true,
            'message' =>
                'Cập nhật trạng thái dịch vụ thành công.',

            'data' => [
                'service' =>
                    new ServiceResource($service),
            ],
        ]);
    }

    private function ensureProvider(
        Request $request
    ): void {
        if ($request->user()->role !== 'PROVIDER') {
            abort(
                403,
                'Bạn không có quyền truy cập.'
            );
        }
    }

    private function ensureOwnsService(
        Request $request,
        Service $service
    ): void {
        $this->ensureProvider($request);

        if (
            $service->provider_id !==
            $request->user()->id
        ) {
            abort(
                403,
                'Bạn không có quyền thao tác dịch vụ này.'
            );
        }
    }

    private function generateUniqueSlug(
        int $providerId,
        string $name,
        ?int $ignoreServiceId = null
    ): string {
        $baseSlug = Str::slug($name);

        if ($baseSlug === '') {
            $baseSlug = 'service';
        }

        $slug = $baseSlug;
        $counter = 2;

        while (
            Service::query()
                ->where(
                    'provider_id',
                    $providerId
                )
                ->where(
                    'slug',
                    $slug
                )
                ->when(
                    $ignoreServiceId !== null,
                    fn ($query) =>
                        $query->where(
                            'id',
                            '!=',
                            $ignoreServiceId
                        )
                )
                ->exists()
        ) {
            $slug =
                $baseSlug . '-' . $counter;

            $counter++;
        }

        return $slug;
    }
}