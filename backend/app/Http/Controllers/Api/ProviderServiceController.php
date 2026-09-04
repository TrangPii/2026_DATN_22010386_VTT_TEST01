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
use Illuminate\Support\Facades\Storage;

class ProviderServiceController extends Controller
{
    public function index(Request $request): JsonResponse
    {
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

        $provider = $request->user();

        $query = Service::query()
            ->where(
                'provider_id',
                $provider->id
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
            $search = trim(
                $validated['search']
            );

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

    // Tạo service mới
    public function store(
        StoreServiceRequest $request
    ): JsonResponse {
        $validated = $request->validated();
        $provider = $request->user();

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

        $slug = $this->generateUniqueSlug(
            $provider->id,
            $validated['name']
        );

        $imagePath = null;

        if ($request->hasFile('image')) {
            $imagePath = $request
                ->file('image')
                ->store(
                    'services',
                    'public'
                );
        }

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
                $imagePath,

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

    // Cập nhật service
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

        $oldImage = $service->image;
        $newImagePath = null;

        if ($request->hasFile('image')) {
            $newImagePath = $request
                ->file('image')
                ->store(
                    'services',
                    'public'
                );

            $validated['image'] =
                $newImagePath;
        }

        $service->update($validated);
        
        if (
            $newImagePath !== null
            && $oldImage
        ) {
            Storage::disk('public')
                ->delete($oldImage);
        }

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

    // ACTIVE / INACTIVE service
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

    private function ensureOwnsService(
        Request $request,
        Service $service
    ): void {
        $user = $request->user();

        if (
            (int) $service->provider_id !==
            (int) $user->id
        ) {
            abort(
                403,
                'Bạn không có quyền thao tác dịch vụ này.'
            );
        }
    }

    // slug duy nhất trong phạm vi một Provider
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