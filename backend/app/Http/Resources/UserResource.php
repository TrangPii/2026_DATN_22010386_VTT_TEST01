<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class UserResource extends JsonResource
{
    public function toArray(
        Request $request
    ): array {
        $providerProfile =
            $this->resource
                ->relationLoaded(
                    'providerProfile'
                )
                ? $this->providerProfile
                : null;

        $canUseProviderMode =
            $this->status === 'ACTIVE'
            && $providerProfile !== null
            && $providerProfile
                ->verification_status ===
                'APPROVED'
            && $providerProfile
                ->provider_status ===
                'ACTIVE';

        return [
            'id' =>
                $this->id,

            'name' =>
                $this->name,

            'email' =>
                $this->email,

            'phone' =>
                $this->phone,

            'avatar' =>
                $this->avatar,

            'role' =>
                $this->role,

            /*
             * User account status.
             * ACTIVE / LOCKED
             */
            'status' =>
                $this->status,

            /*
             * Trạng thái xét duyệt Provider:
             * null
             * PENDING
             * APPROVED
             * REJECTED
             */
            'provider_verification_status' =>
                $providerProfile
                    ?->verification_status,

            /*
             * Trạng thái hoạt động Provider:
             * null
             * ACTIVE
             * LOCKED
             */
            'provider_status' =>
                $providerProfile
                    ?->provider_status,

            /*
             * Chỉ TRUE khi:
             * User ACTIVE
             * + Provider APPROVED
             * + Provider ACTIVE
             */
            'can_use_provider_mode' =>
                $canUseProviderMode,

            'email_verified_at' =>
                $this->email_verified_at
                    ?->toISOString(),

            'last_login_at' =>
                $this->last_login_at
                    ?->toISOString(),

            'provider_profile' =>
                $this->whenLoaded(
                    'providerProfile',
                    function (): ?array {
                        if (
                            $this
                                ->providerProfile ===
                            null
                        ) {
                            return null;
                        }

                        return [
                            'id' =>
                                $this
                                    ->providerProfile
                                    ->id,

                            'business_name' =>
                                $this
                                    ->providerProfile
                                    ->business_name,

                            'description' =>
                                $this
                                    ->providerProfile
                                    ->description,

                            'address' =>
                                $this
                                    ->providerProfile
                                    ->address,

                            'experience_years' =>
                                $this
                                    ->providerProfile
                                    ->experience_years,

                            'average_rating' =>
                                $this
                                    ->providerProfile
                                    ->average_rating,

                            'total_reviews' =>
                                $this
                                    ->providerProfile
                                    ->total_reviews,

                            'verification_status' =>
                                $this
                                    ->providerProfile
                                    ->verification_status,

                            'provider_status' =>
                                $this
                                    ->providerProfile
                                    ->provider_status,

                            'verified_at' =>
                                $this
                                    ->providerProfile
                                    ->verified_at
                                    ?->toISOString(),
                        ];
                    }
                ),

            'created_at' =>
                $this->created_at
                    ?->toISOString(),

            'updated_at' =>
                $this->updated_at
                    ?->toISOString(),
        ];
    }
}