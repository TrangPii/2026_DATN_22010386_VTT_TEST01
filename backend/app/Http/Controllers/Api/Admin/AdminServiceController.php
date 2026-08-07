<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Http\Resources\ServiceResource;
use App\Models\Service;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AdminServiceController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'status' => [
                'nullable',
                'in:ACTIVE,INACTIVE',
            ],

            'provider_id' => [
                'nullable',
                'integer',
                'exists:users,id',
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
                'max:100',
            ],
        ]);

        $query = Service::query()
            ->with([
                'category',
                'provider.providerProfile',
            ])
            ->latest();

        foreach (
            ['status', 'provider_id', 'category_id']
            as $field
        ) {
            if (! empty($validated[$field])) {
                $query->where(
                    $field,
                    $validated[$field]
                );
            }
        }

        if (! empty($validated['search'])) {
            $query->where(
                'name',
                'like',
                '%' .
                $validated['search'] .
                '%'
            );
        }

        $services = $query->paginate(
            $validated['per_page'] ?? 20
        );

        return response()->json([
            'success' => true,
            'message' =>
                'Lấy danh sách dịch vụ thành công.',

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

                    'total' =>
                        $services->total(),
                ],
            ],
        ]);
    }

    public function updateStatus(
        Request $request,
        Service $service
    ): JsonResponse {
        $validated = $request->validate([
            'status' => [
                'required',
                'in:ACTIVE,INACTIVE',
            ],
        ]);

        $service->update([
            'status' =>
                $validated['status'],
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
}