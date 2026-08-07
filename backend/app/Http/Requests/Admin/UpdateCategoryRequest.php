<?php

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateCategoryRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()?->role === 'ADMIN';
    }

    public function rules(): array
    {
        $category = $this->route('category');

        return [
            'name' => [
                'sometimes',
                'required',
                'string',
                'min:2',
                'max:255',

                Rule::unique(
                    'service_categories',
                    'name'
                )->ignore($category?->id),
            ],

            'description' => [
                'sometimes',
                'nullable',
                'string',
                'max:2000',
            ],

            'image' => [
                'sometimes',
                'nullable',
                'string',
                'max:255',
            ],

            'display_order' => [
                'sometimes',
                'integer',
                'min:0',
            ],
        ];
    }
}