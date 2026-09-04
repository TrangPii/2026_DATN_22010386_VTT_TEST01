<?php

namespace App\Http\Requests\Service;

use Illuminate\Foundation\Http\FormRequest;

class UpdateServiceRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'category_id' => [
                'sometimes',
                'required',
                'integer',
                'exists:service_categories,id',
            ],

            'name' => [
                'sometimes',
                'required',
                'string',
                'min:3',
                'max:255',
            ],

            'description' => [
                'sometimes',
                'nullable',
                'string',
                'max:3000',
            ],

            'price' => [
                'sometimes',
                'required',
                'numeric',
                'min:0',
                'max:9999999999999.99',
            ],

            'price_unit' => [
                'sometimes',
                'required',
                'string',
                'max:50',
            ],

            'estimated_duration_minutes' => [
                'sometimes',
                'nullable',
                'integer',
                'min:1',
                'max:1440',
            ],

            'image' => [
                'sometimes',
                'nullable',
                'image',
                'mimes:jpg,jpeg,png,webp',
                'max:4096',
            ],
        ];
    }
}